defmodule App.Repo.Migrations.CreateCourses do
  use Ecto.Migration

  def change do
    create table(:courses) do
      add :name, :string
      add :department, :string
      add :number, :integer

      timestamps()
    end

  end
end
