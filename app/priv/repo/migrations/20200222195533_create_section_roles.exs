defmodule App.Repo.Migrations.CreateSectionRoles do
  use Ecto.Migration

  def change do
    create table(:section_roles) do
      add :role, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :section_id, references(:sections, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
