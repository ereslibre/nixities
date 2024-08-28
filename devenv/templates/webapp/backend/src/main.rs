use axum::{
    extract::State,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
    Json, Router,
};
use core::result::Result;
use serde::{Deserialize, Serialize};
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
        .route("/", get(root))
        .route("/user", post(create_user))
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3000")
        .await
        .expect("failed to bind to port");
    axum::serve(listener, app)
        .await
        .expect("failed to start server");

    Ok(())
}

async fn root(State(pool): State<SqlitePool>) -> Result<String, BackendError> {
    let recs = sqlx::query!(
        r#"
SELECT id, name
FROM samples
ORDER BY id
        "#
    )
    .fetch_all(&pool)
    .await?;

    for rec in recs {
        println!("- [{}] {}", rec.id, &rec.name,);
    }

    Ok(String::from("Hello, world!"))
}

impl From<sqlx::Error> for BackendError {
    fn from(_: sqlx::Error) -> Self {
        BackendError()
    }
}

async fn create_user(Json(payload): Json<CreateUser>) -> (StatusCode, Json<User>) {
    let user = User {
        id: 1337,
        username: payload.username,
    };

    (StatusCode::CREATED, Json(user))
}

#[derive(Deserialize)]
struct CreateUser {
    username: String,
}

#[derive(Serialize)]
struct User {
    id: u64,
    username: String,
}
