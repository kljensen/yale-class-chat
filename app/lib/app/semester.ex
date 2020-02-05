defmodule App.Semester do
  use Ecto.Schema

  schema "semesters" do
    field :name, :string
    has_many :courses, App.Course
  end

  def changeset(semester, params \\ %{}) do
    semester
    |> Ecto.Changeset.cast(params, [:name])
    |> Ecto.Changeset.validate_required([:name])
  end
end
