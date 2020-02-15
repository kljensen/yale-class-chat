defmodule App.Repo.Migrations.CreateRatings do
  use Ecto.Migration

  def change do
    create table(:ratings) do
      add :score, :integer
      add :submission_id, references(:submissions)
      add :user_id, references(:users)

      timestamps()
    end
  end
end
