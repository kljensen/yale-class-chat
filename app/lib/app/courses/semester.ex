defmodule App.Courses.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field :name, :string
    has_many :courses, App.Courses.Course

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
