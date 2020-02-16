defmodule App.Submissions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :description, :string
    field :title, :string
    belongs_to :submission, App.Submissions.Submission

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
