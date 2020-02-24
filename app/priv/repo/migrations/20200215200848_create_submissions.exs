defmodule App.Repo.Migrations.CreateSubmissions do
  use Ecto.Migration

  def change do
    create table(:submissions) do
      add :title, :string
      add :description, :string
      add :slug, :string
      add :image_url, :string
      add :topic_id, references(:topics, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:submissions, [:slug])
  end
end
