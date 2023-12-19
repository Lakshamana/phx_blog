defmodule PhxBlogWeb.UserController do
  use PhxBlogWeb, :controller

  alias PhxBlog.Accounts
  alias PhxBlog.Accounts.User

  plug :check_user_exists when action in [:show, :update, :delete]
  plug :check_email_plug when action in [:update]

  action_fallback PhxBlogWeb.FallbackController

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, :index, users: users)
  end

  @create_params %{
    "email" => [type: :string, required: true, func: &User.validate_email/1],
    "password" => [type: :string, required: true, func: &User.validate_password/1]
  }
  def create(conn, %{"user" => user_params}) do
    with {:ok, params} <- Tarams.cast(user_params, @create_params) do
      with {:ok, %User{} = user} <- Accounts.create_user(params) do
        conn
        |> put_status(:created)
        |> put_resp_header("location", ~p"/api/users/#{user}")
        |> render(:show, user: user)
      end
    else
      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, errors: errors)
    end
  end

  @check_email %{"email" => [type: :string, required: true, func: &User.validate_email/1]}
  def check_email(conn, payload) do
    with {:ok, _} <- Tarams.cast(payload, @check_email) do
      :ok
    else
      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, errors: errors)
    end
  end

  def show(conn, _), do: render(conn, :show, user: conn.assigns.model)

  @update_params %{
    "user" => [
      required: true,
      type: %{
        "password" => [
          type: :string,
          func: &User.validate_password/1,
          length: [min: 6, max: 16]
        ]
      }
    ]
  }
  def update(conn, payload) do
    with {:ok, _} <- Tarams.cast(payload, @update_params) do
      %{"user" => user_params} = payload

      with {:ok, %User{} = user} <- Accounts.update_user(conn.assigns.model, user_params) do
        render(conn, :show, user: user)
      end
    else
      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, errors: errors)
    end
  end

  def delete(conn, _) do
    with {:ok, %User{}} <- Accounts.delete_user(conn.assigns.model) do
      send_resp(conn, :no_content, "")
    end
  end

  @check_email_plug %{
    "user" => [
      required: true,
      type: %{
        "email" => [type: :string, func: &User.validate_email/1]
      }
    ]
  }
  defp check_email_plug(conn, _) do
    with {:ok, params} <- Tarams.cast(conn.params, @check_email_plug) do
      email = params["user"]["email"]

      if email do
        user = Accounts.get_user_by_email(email)

        case user do
          nil ->
            conn

          _ ->
            conn
            |> put_status(:conflict)
            |> render(:email_already_exists)
            |> halt()
        end
      else
        conn
      end
    else
      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, errors: errors)
        |> halt()
    end
  end

  @check_user_exists %{
    "id" => [type: :string, required: true]
  }
  defp check_user_exists(conn, _) do
    with {:ok, params} <- Tarams.cast(conn.params, @check_user_exists) do
      try do
        user = Accounts.get_user!(params["id"])

        assign(conn, :model, user)
      rescue
        _ ->
          conn
          |> put_status(:not_found)
          |> render(:user_not_found)
          |> halt()
      end
    else
      {:error, errors} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:errors, errors: errors)
        |> halt()
    end
  end
end
