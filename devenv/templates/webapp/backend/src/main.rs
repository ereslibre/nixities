mod db;
mod errors;
mod users;
mod version;

use axum::{
    routing::{get, post},
    Router,
};
use core::result::Result;
use sqlx::SqlitePool;
use std::env;
use tracing::info;

use crate::errors::BackendError;

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
        .route("/users", get(users::list_users))
        .route("/users", post(users::create_user))
        .with_state(pool);

    let listener = tokio::net::TcpListener::bind("0.0.0.0:3002")
        .await
        .expect("failed to bind to port");
    axum::serve(listener, app)
        .await
        .expect("failed to start server");

    Ok(())
}
