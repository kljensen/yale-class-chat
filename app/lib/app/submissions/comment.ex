defmodule App.Submissions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :description, :string
    field :title, :string
    belongs_to :submission, App.Submissions.Submission
    belongs_to :user, App.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:title, :description, :submission_id, :user_id])
    |> validate_required([:title, :description])
    |> foreign_key_constraint(:user_id)
    |> assoc_constraint(:user)
    |> foreign_key_constraint(:submission_id)
    |> assoc_constraint(:submission)
  end
end
