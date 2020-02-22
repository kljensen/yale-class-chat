defmodule App.Repo.Migrations.CreateCourseRoles do
  use Ecto.Migration

  def change do
    create table(:course_roles) do
      add :role, :string
      add :valid_from, :utc_datetime
      add :valid_to, :utc_datetime
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :course_id, references(:courses, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
