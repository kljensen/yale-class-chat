defmodule App.Submission do
  use Ecto.Schema
  import Ecto.Changeset

  schema "submissions" do
    field :title, :string
    field :description, :string
    field :slug, :string
    field :image_url, :string
    belongs_to :topic, App.Topic

    timestamps()
  end

  def changeset(user, params \\ %{}) do
    user
    |> cast(params, [:title, :description, :slug])
    |> validate_required([:title, :description, :slug])
    |> unique_constraint(:slug)
  end
end
