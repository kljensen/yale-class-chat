defmodule App.Submission do
  use Ecto.Schema

  schema "submissions" do
    field :title, :string
    field :description, :string
    field :slug, :string
    field :image_url, :string
    belongs_to :topic, App.Topic
  end

  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:title, :description, :slug])
    |> Ecto.Changeset.validate_required([:title, :description, :slug])
    |> Ecto.Changeset.unsafe_validate_unique([:slug], App.Repo, message: "slug is already in use")
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
