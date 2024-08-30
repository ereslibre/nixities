use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use chrono::{DateTime, Utc};
use core::result::Result;
use serde::Deserialize;
use sqlx::SqlitePool;
use std::env;

#[derive(Clone, Debug)]
struct BackendError();

impl IntoResponse for BackendError {
    fn into_response(self) -> Response {
        (
            StatusCode::INTERNAL_SERVER_ERROR,
            String::from("Something went wrong"),
        )
            .into_response()
    }
}

#[tokio::main]
async fn main() -> Result<(), BackendError> {
    tracing_subscriber::fmt::init();

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
    fn from(_: sqlx::Error) -> Self {
        BackendError()
    }
}

async fn create_user(
    State(pool): State<SqlitePool>,
    Json(payload): Json<CreateUser>,
) -> (StatusCode, Json<v1::User>) {
    let user = User {
        id: uuid::Uuid::new_v4().as_simple().to_string(),
        username: payload.username,
        created_at: Utc::now(),
        updated_at: None,
        deleted_at: None,
    };

    if let Err(_err) = sqlx::query("INSERT INTO users(id, username, created_at) VALUES (?, ?, ?)")
        .bind(&user.id)
        .bind(&user.username)
        .bind(user.created_at.timestamp())
        .execute(&pool)
        .await
    {
        // FIXME: do not return a default user, but an empty response instead
        return (
            StatusCode::INTERNAL_SERVER_ERROR,
            Json(User::default().into()),
        );
    }

    (StatusCode::CREATED, Json(user.into()))
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
