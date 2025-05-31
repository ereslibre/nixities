use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
};
use serde::Serialize;

#[derive(Debug, Serialize, utoipa::ToSchema)]
pub enum BackendError {
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

impl From<sqlx::Error> for BackendError {
    fn from(_err: sqlx::Error) -> Self {
        BackendError::DatabaseError
    }
}
