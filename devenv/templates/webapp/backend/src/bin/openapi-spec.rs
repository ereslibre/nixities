use utoipa::OpenApi;

#[derive(OpenApi)]
#[openapi(paths(backend::users::create_user, backend::users::list_users))]
struct ApiDoc;

fn main() {
    println!("{}", ApiDoc::openapi().to_pretty_json().unwrap())
}
