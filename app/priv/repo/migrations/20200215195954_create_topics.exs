defmodule App.Repo.Migrations.CreateTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :description, :text
      add :slug, :string
      add :opened_at, :utc_datetime
      add :closed_at, :utc_datetime
      add :allow_submissions, :boolean, default: false, null: false
      add :allow_submission_voting, :boolean, default: false, null: false
      add :anonymous, :boolean, default: false, null: false
      add :allow_submission_comments, :boolean, default: false, null: false
      add :allow_ranking, :boolean, default: false, null: false
      add :show_submission_comments, :boolean, default: true, null: false
      add :show_submission_ratings, :boolean, default: true, null: false
      add :show_user_submissions, :boolean, default: false, null: false
      add :visible, :boolean, default: true, null: false
      add :user_submission_limit, :integer
      add :sort, :string
      add :type, :string, null: false
      add :section_id, references(:sections, on_delete: :delete_all), null: false

      timestamps()
    end
  end
end
