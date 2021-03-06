defmodule Todolist.Account.User do
  use Ecto.Schema
  import Ecto.Changeset
  import Comeonin.Bcrypt, only: [hashpwsalt: 1]

  schema "users" do
    field :email, :string
    field :username, :string
    field :password_hash, :string
    field :role, :id

    # Virtual fields:
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true

    # Association
    #has_many :usersteams, Todolist.Association.UserTeam
    many_to_many :teams, Todolist.Account.Team, join_through: "usersteams", on_replace: :delete

    timestamps()
  end

  @email ~r/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :role, :password, :password_confirmation])
    |> unique_constraint(:email)
    |> validate_required([:username, :email, :role, :password, :password_confirmation])
    |> validate_format(:email, @email, message: "must be a valid email address")
    |> validate_length(:password, min: 8) # Check that password length is >= 8
    |> validate_confirmation(:password) # Check that password === password_confirmation
    |> put_password_hash
  end

  def changeset_update(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :role])
    |> unique_constraint(:email)
    |> validate_required([:username, :email, :role])
    |> validate_format(:email, @email, message: "must be a valid email address")
    |> validate_length(:password, min: 8) # Check that password length is >= 8
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}}
        ->
          put_change(changeset, :password_hash, hashpwsalt(pass))
      _ ->
          changeset
    end
  end
end
