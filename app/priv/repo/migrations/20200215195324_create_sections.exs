defmodule App.Repo.Migrations.CreateSections do
  use Ecto.Migration

  def change do
    create table(:sections) do
      add :title, :string
      add :crn, :string

      timestamps()
    end

    create unique_index(:sections, [:crn])
  end
end
