defmodule App.Repo.Migrations.CreateSemesters do
  use Ecto.Migration

  def change do
    create table(:semesters) do
      add :name, :string
    end
  end
end
