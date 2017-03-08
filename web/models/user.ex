defmodule PhoenixCurator.User do
  use PhoenixCurator.Web, :model

  # Use Curator Modules (as needed).
  use CuratorDatabaseAuthenticatable.Schema
  use CuratorConfirmable.Schema

  schema "users" do
    field :email, :string

    # Add Curator Module fields (as needed).
    curator_database_authenticatable_schema
    curator_confirmable_schema

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end

  # CuratorRegisterable
  def create_registration_changeset(user, params \\ %{}) do
    user
    |> changeset(params)
    |> password_changeset(params)
  end

  def update_registration_changeset(user, params \\ %{}) do
    user
    |> changeset(params)
  end
end
