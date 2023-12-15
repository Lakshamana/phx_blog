defmodule PhxBlogWeb.SessionJSON do
  alias PhxBlog.Accounts.User

  @doc """
  Renders a user and token
  """
  def user_token(%{user: user, token: token}) do
    %{data: data(user, token)}
  end

  def render(template, _assigns) do
    %{errors: %{detail: Phoenix.Controller.status_message_from_template(template)}}
  end

  defp data(%User{} = user, token) do
    %{
      id: user.id,
      email: user.email,
      token: token
    }
  end
end
