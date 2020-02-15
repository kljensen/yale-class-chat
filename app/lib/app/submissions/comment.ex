defmodule App.Submissions.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :description, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end
end
