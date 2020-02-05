defmodule App.Topic do
  use Ecto.Schema

  schema "topics" do
    field :title, :string
    field :description, :string
    field :slug, :string
    field :opened_at, :utc_datetime
    field :closed_at, :utc_datetime
    field :allow_submissions, :boolean
    field :allow_submission_voting, :boolean
    field :anonymous, :boolean
    field :allow_submission_comments, :boolean
    field :user_submission_limit, :integer
    field :sort, :string
    belongs_to :section, App.Section
  end

  def changeset(topic, params \\ %{}) do
    topic
    |> Ecto.Changeset.cast(params, [:title, :description, :slug, :opened_at, :closed_at, :allow_submissions, :allow_submission_voting, :anonymous, :allow_submission_comments, :sort])
    |> Ecto.Changeset.validate_required([:title, :slug, :opened_at, :allow_submissions, :allow_submission_voting, :anonymous, :allow_submission_comments, :sort])
  end
end
