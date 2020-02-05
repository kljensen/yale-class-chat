defmodule App.Repo.Migrations.CreateUserRoles do
  use Ecto.Migration

  def change do
    create table(:user_roles) do
      add :role, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime
      add :section_id, references(:section)
      add :user_id, references(:users)
    end
  end
end
