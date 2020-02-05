defmodule App.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :title, :string
      add :crn, :string
      add :course_id, references(:courses)
    end
  end
end
