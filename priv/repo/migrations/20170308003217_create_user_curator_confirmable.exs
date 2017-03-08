defmodule PhoenixCurator.Repo.Migrations.CreateUserCuratorConfirmable do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :confirmed_at, :utc_datetime
      add :confirmation_token, :string
      add :confirmation_sent_at, :utc_datetime
    end

    create unique_index(:users, [:confirmation_token])
  end
end
