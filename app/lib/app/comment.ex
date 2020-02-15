defmodule App.Comment do
  use Ecto.Schema

  schema "comments" do
    field :title, :string
    field :description, :string
    belongs_to :submission, App.Submission
    belongs_to :user, App.User

    timestamps()
  end

  def changeset(comment, params \\ %{}) do
    comment
    |> Ecto.Changeset.cast(params, [:title, :description])
    |> Ecto.Changeset.validate_required([:title, :description])
  end
end
