defmodule App.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :description, :string
      add :slug, :string
      add :opened_at, :utc_datetime
      add :closed_at, :utc_datetime
      add :allow_submissions, :boolean, default: false, null: false
      add :allow_submission_voting, :boolean, default: false, null: false
      add :anonymous, :boolean, default: false, null: false
      add :allow_submission_comments, :boolean, default: false, null: false
      add :user_submission_limit, :integer
      add :sort, :string
      add :section_id, references(:sections)

      timestamps()
    end

    create unique_index(:topics, [:slug])
  end
end
