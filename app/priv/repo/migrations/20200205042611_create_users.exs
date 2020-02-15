defmodule App.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :net_id, :string
      add :display_name, :string
      add :email, :string

      timestamps()
    end

    create unique_index(:users, [:net_id])
  end
end
