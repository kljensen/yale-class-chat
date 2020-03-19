defmodule App.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :score, :integer
      add :submission_id, references(:submissions, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:ratings, [:submission_id, :user_id], name: :one_rating_per_user)
  end
end
