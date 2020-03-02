defmodule App.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :department, :string
      add :number, :integer
      add :allow_write, :boolean, default: true, null: false
      add :allow_read, :boolean, default: true, null: false
      add :semester_id, references(:semesters, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
