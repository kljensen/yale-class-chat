defmodule App.Section do
  use Ecto.Schema

  schema "sections" do
    field :title, :string
    field :crn, :string
    belongs_to :course, App.Course
  end

  def changeset(section, params \\ %{}) do
    section
    |> Ecto.Changeset.cast(params, [:title])
    |> Ecto.Changeset.validate_required([:title])
  end
end
