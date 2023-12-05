defmodule PhxBlog.Accounts.Pipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :phx_blog,
    error_handler: PhxBlog.Accounts.ErrorHandler,
    module: PhxBlog.Accounts.Guardian

  # This plug is responsible for fetching a resource using a session token
  plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}

  # This is plug is responsible for verifying that the header contains a access token
  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}

  # Load user if either of the above plugs succeeded
  plug Guardian.Plug.LoadResource, allow_blank: true
end
