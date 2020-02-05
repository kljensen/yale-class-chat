defmodule App.Course do
  use Ecto.Schema

  schema "courses" do
    field :name, :string
    field :department, :string
    field :number, :integer
    belongs_to :semester, App.Semester
  end

  def changeset(course, params \\ %{}) do
    course
    |> Ecto.Changeset.cast(params, [:net_id])
    |> Ecto.Changeset.validate_required([:name])
  end
end
