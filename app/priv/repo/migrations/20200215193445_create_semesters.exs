defmodule App.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :name, :string

      timestamps()
    end

    create unique_index(:semesters, [:name])
  end
end
