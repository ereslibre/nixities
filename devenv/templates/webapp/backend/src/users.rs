use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    Json,
};
use chrono::{DateTime, Utc};
use core::result::Result;
use serde::{Deserialize, Serialize};
use sqlx::SqlitePool;

use crate::{
    db::{identify_database_error, DatabaseError},
    errors::BackendError,
};

#[derive(Default)]
pub struct User {
    id: String,
    username: String,
    created_at: DateTime<Utc>,
    updated_at: Option<DateTime<Utc>>,
    deleted_at: Option<DateTime<Utc>>,
}

#[derive(Deserialize, utoipa::ToSchema)]
pub struct CreateUser {
    username: String,
}

#[derive(Serialize, utoipa::ToSchema)]
pub enum CreateUserResponse {
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

#[utoipa::path(get, path = "/users", responses((status = OK, body = Vec<v1::User>)))]
pub async fn list_users(
    State(pool): State<SqlitePool>,
) -> Result<Json<Vec<v1::User>>, BackendError> {
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

#[utoipa::path(post, path = "/users", responses((status = OK, body = CreateUserResponse)))]
pub async fn create_user(
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

    if let Err(err) = sqlx::query("INSERT INTO users(id, username, created_at) VALUES (?, ?, ?)")
        .bind(&user.id)
        .bind(&user.username)
        .bind(user.created_at.timestamp())
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

mod v1 {

    use serde::Serialize;

    #[derive(Serialize, utoipa::ToSchema)]
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
