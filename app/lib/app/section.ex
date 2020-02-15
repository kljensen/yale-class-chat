defmodule App.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sections" do
    field :title, :string
    field :crn, :string
    belongs_to :course, App.Course

    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> unique_constraint(:crn)
  end
end
