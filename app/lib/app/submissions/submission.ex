defmodule App.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :description, :string
    field :image_url, EctoFields.URL
    field :slug, :string
    field :title, :string
    field :allow_ranking, :boolean, default: false
    field :visible, :boolean, default: true
    belongs_to :topic, App.Topics.Topic
    belongs_to :user, App.Accounts.User
    has_many :comments, App.Submissions.Comment
    has_many :ratings, App.Submissions.Rating

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:title, :description, :slug, :image_url, :allow_ranking, :visible])
    |> validate_required([:title, :description, :slug, :allow_ranking, :visible])
    |> foreign_key_constraint(:topic_id)
    |> assoc_constraint(:topic)
    |> foreign_key_constraint(:user_id)
    |> assoc_constraint(:user)
  end
end
