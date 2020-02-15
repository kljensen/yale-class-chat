defmodule App.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :department, :string
      add :number, :integer
      add :semester_id, references(:semesters)

      timestamps()
    end
  end
end
