defmodule App.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :title, :string
      add :description, :string
      add :slug, :string
      add :image_url, :string

      timestamps()
    end

    create unique_index(:submissions, [:slug])
  end
end
