defmodule PhxBlogWeb.UserJSON do
  alias PhxBlog.Accounts.User

  @doc """
  Renders a list of users.
  """
  def index(%{users: users}) do
    %{data: for(user <- users, do: data(user))}
  end

  @doc """
  Renders a single user.
  """
  def show(%{user: user}) do
    %{data: data(user)}
  end

  def create(%{user: user, token: token}) do
    %{data: data(user, token)}
  end

  def errors(%{errors: payload}), do: payload

  def email_already_exists(_) do
    %{error: "Email already exists"}
  end

  def email_available(_) do
    %{error: "Email available"}
  end

  def user_not_found(_) do
    %{error: "User not found"}
  end

  defp data(%User{} = user) do
    %{
      id: user.id,
      email: user.email
    }
  end

  defp data(%User{} = user, token) do
    %{
      id: user.id,
      email: user.email,
      token: token
    }
  end
end
