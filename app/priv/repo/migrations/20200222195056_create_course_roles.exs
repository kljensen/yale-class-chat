defmodule App.Repo.Migrations.CreateCourseRoles do
  use Ecto.Migration

  def change do
    create table(:course_roles) do
      add :role, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime

      timestamps()
    end

  end
end
