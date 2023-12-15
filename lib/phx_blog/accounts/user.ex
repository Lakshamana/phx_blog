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

  defp check_email(email) do
    # require IEx; IEx.pry
    email |> String.match?(~r/^[\w\-\.]+@([\w-]+\.)+[\w-]{2,}$/m)
  end

  def validate_email(changeset) do
    # require IEx; IEx.pry

    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{email: email}} ->
        check_email(email) && changeset || add_error(changeset, :email, "'#{email}' is not a valid email address")

      _ ->
        changeset
    end
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> password_hash()
    |> validate_email()
  end
end
