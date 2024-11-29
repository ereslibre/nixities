mod db;
mod version;

use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use chrono::{DateTime, Utc};
use core::result::Result;
use serde::{Deserialize, Serialize};
use sqlx::SqlitePool;
use std::env;
use tracing::info;

use db::{identify_database_error, DatabaseError};

#[derive(Debug, Serialize)]
enum BackendError {
    DatabaseError,
}

impl IntoResponse for BackendError {
    fn into_response(self) -> Response {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            String::from("Something unexpected happened"),
        )
            .into_response()
    }
}

#[tokio::main]
async fn main() -> Result<(), BackendError> {
    tracing_subscriber::fmt::init();

    info!(
        "Welcome to Backend (git revision {git_revision})",
        git_revision = version::GIT_REVISION,
    );

    let pool = SqlitePool::connect(&env::var("DATABASE_URL").expect("missing DATABASE_URL envvar"))
        .await
        .expect("could not connect to database");

    let app = Router::new()
        .route("/users", get(list_users))
        .route("/users", post(create_user))
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .expect("failed to bind to port");
    axum::serve(listener, app)
        .await
        .expect("failed to start server");

    Ok(())
}

async fn list_users(State(pool): State<SqlitePool>) -> Result<Json<Vec<v1::User>>, BackendError> {
    let users = sqlx::query!("SELECT id, username FROM users ORDER BY created_at")
        .fetch_all(&pool)
        .await?;

    let mut result: Vec<v1::User> = Vec::new();

    for user in users {
        result.push(v1::User {
            id: user.id,
            username: user.username,
        })
    }

    Ok(Json(result))
}

impl From<sqlx::Error> for BackendError {
    fn from(_err: sqlx::Error) -> Self {
        BackendError::DatabaseError
    }
}

#[derive(Serialize)]
enum CreateUserResponse {
    User(v1::User),
    BadRequest,
    BackendError(BackendError),
}

impl IntoResponse for CreateUserResponse {
    fn into_response(self) -> Response {
        match self {
            CreateUserResponse::User(user) => (StatusCode::CREATED, Json(user)).into_response(),
            CreateUserResponse::BadRequest => {
                (StatusCode::BAD_REQUEST, axum::body::Body::empty()).into_response()
            }
            CreateUserResponse::BackendError(_) => {
                (StatusCode::INTERNAL_SERVER_ERROR, axum::body::Body::empty()).into_response()
            }
        }
    }
}

async fn create_user(
    State(pool): State<SqlitePool>,
    Json(payload): Json<CreateUser>,
) -> impl IntoResponse {
    let user = User {
        id: uuid::Uuid::new_v4().as_simple().to_string(),
        username: payload.username,
        created_at: Utc::now(),
        updated_at: None,
        deleted_at: None,
    };

    let user_id = &user.id;
    let user_username = &user.username;
    let created_at_timestamp = user.created_at.timestamp();

    if let Err(err) = sqlx::query!(
        "INSERT INTO users(id, username, created_at) VALUES (?, ?, ?)",
        user_id,
        user_username,
        created_at_timestamp,
    )
    .execute(&pool)
    .await
    {
        if let Some(database_error) = err.as_database_error() {
            match identify_database_error(database_error) {
                DatabaseError::UniqueConstraintFailed => return CreateUserResponse::BadRequest,
                DatabaseError::Other => {
                    return CreateUserResponse::BackendError(BackendError::DatabaseError)
                }
            }
        }

        return CreateUserResponse::BackendError(BackendError::DatabaseError);
    }

    CreateUserResponse::User(user.into())
}

#[derive(Deserialize)]
struct CreateUser {
    username: String,
}

#[derive(Default)]
struct User {
    id: String,
    username: String,
    created_at: DateTime<Utc>,
    updated_at: Option<DateTime<Utc>>,
    deleted_at: Option<DateTime<Utc>>,
}

mod v1 {

    use serde::Serialize;

    #[derive(Serialize)]
    pub struct User {
        pub id: String,
        pub username: String,
    }

    impl From<super::User> for User {
        fn from(user: super::User) -> Self {
            Self {
                id: user.id,
                username: user.username,
            }
        }
    }
}
