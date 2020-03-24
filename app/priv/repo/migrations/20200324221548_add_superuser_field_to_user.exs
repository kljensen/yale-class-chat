defmodule App.Repo.Migrations.AddSuperuserFieldToUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_superuser, :boolean, null: false, default: false
    end
  end
end
