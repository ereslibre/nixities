use sqlx::error::DatabaseError as SqlxDatabaseError;

pub enum DatabaseError {
    UniqueConstraintFailed,
    Other,
}

pub fn identify_database_error(database_error: &dyn SqlxDatabaseError) -> DatabaseError {
    if let Some(error_code) = database_error.code() {
        if error_code == std::borrow::Cow::Borrowed("2067") {
            return DatabaseError::UniqueConstraintFailed;
        }
    }
    DatabaseError::Other
}
