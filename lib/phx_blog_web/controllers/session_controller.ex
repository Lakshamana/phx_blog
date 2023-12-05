defmodule PhxBlogWeb.SessionController do
  use PhxBlogWeb, :controller

  action_fallback PhxBlogWeb.FallbackController

  alias PhxBlog.{Accounts, Accounts.Guardian}

  def login(conn, %{email: email, password: password}) do
    case Accounts.authenticate_user(email, password) do  # calling model layer
      {:ok, user} ->
        {:ok, token, _claims} = Guardian.encode_and_sign(user)
        conn
        |> put_status(:ok)
        |> render(:user_token, user: user, token: token)
      {:error, _reason} ->
        conn
        |> put_status(:unauthorized)
        |> render(%{error: "Invalid credentials"})
    end
  end

  def logout(conn, _) do
    conn
    |> Guardian.Plug.sign_out()
    |> put_status(:ok)
    |> json(%{msg: "Logged out"})
  end
end
