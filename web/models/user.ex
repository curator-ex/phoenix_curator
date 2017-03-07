defmodule PhoenixCurator.User do
  use PhoenixCurator.Web, :model

  # Use Curator Modules (as needed).
  # use CuratorDatabaseAuthenticatable.Schema

  schema "users" do
    field :email, :string

    # Add Curator Module fields (as needed).
    # curator_database_authenticatable_schema

    timestamps
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:email])
    |> validate_required([:email])
    |> validate_format(:email, ~r/@/)
    |> unique_constraint(:email)
  end
end
