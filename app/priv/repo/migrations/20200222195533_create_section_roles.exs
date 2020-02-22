defmodule App.Repo.Migrations.CreateSectionRoles do
  use Ecto.Migration

  def change do
    create table(:section_roles) do
      add :role, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime

      timestamps()
    end

  end
end
