defmodule App.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :score, :integer
      add :submission_id, references(:submissions, on_delete: :delete_all), null: false

      timestamps()
    end

  end
end
