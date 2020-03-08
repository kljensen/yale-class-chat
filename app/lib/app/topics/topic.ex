defmodule App.Topics.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :allow_ranking, :boolean, default: false
    field :allow_submission_comments, :boolean, default: false
    field :allow_submission_voting, :boolean, default: false
    field :allow_submissions, :boolean, default: false
    field :anonymous, :boolean, default: false
    field :closed_at, :utc_datetime
    field :description, :string
    field :show_user_submissions, :boolean, default: false
    field :visible, :boolean, default: true
    field :opened_at, :utc_datetime
    field :slug, :string
    field :sort, :string
    field :title, :string
    field :user_submission_limit, :integer
    belongs_to :section, App.Courses.Section
    timestamps()
  end

  @doc false
  def changeset(topic, attrs) do
    topic
    |> cast(attrs, [:title, :description, :slug, :opened_at, :closed_at, :allow_submissions, :allow_submission_voting, :anonymous, :allow_submission_comments, :user_submission_limit, :sort, :allow_ranking, :show_user_submissions, :visible])
    |> validate_required([:title, :description, :slug, :opened_at, :closed_at, :allow_submissions, :allow_submission_voting, :anonymous, :allow_submission_comments, :user_submission_limit, :sort, :allow_ranking, :show_user_submissions, :visible])
    |> foreign_key_constraint(:section_id)
    |> assoc_constraint(:section)
  end
end
