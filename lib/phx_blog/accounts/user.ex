defmodule PhxBlog.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "users" do
    field :email, :string
    field :password_hash, :string, redact: true
    field :password, :string, virtual: true

    timestamps()
  end

  @doc false
  defp password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Bcrypt.hash_pwd_salt(password))

      %Ecto.Changeset{valid?: true, changes: _} ->
        changeset

      %Ecto.Changeset{valid?: false} ->
        changeset
    end
  end

  def validate_email(email) do
    if email |> String.match?(~r/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/m),
      do: :ok,
      else: {:error, "not a valid email address"}
  end

  def validate_password(password) do
    if password |> String.match?(~r/^[a-zA-Z0-9]*$/),
      do: :ok,
      else: {:error, "password must be alphanumeric"}
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> unique_constraint(:email)
    |> password_hash()
  end
end
