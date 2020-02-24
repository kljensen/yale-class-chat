defmodule App.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :title, :string
      add :description, :string
      add :submission_id, references(:submissions, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end