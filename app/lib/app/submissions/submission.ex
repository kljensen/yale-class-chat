defmodule App.Submissions.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :description, :string
    field :image_url, :string
    field :slug, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(submission, attrs) do
    submission
    |> cast(attrs, [:title, :description, :slug, :image_url])
    |> validate_required([:title, :description, :slug, :image_url])
    |> unique_constraint(:slug)
  end
end
