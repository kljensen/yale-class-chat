defmodule App.Courses.Semester do
  use Ecto.Schema
  import Ecto.Changeset

  schema "semesters" do
    field :name, :string
    field :term_code, :string
    has_many :courses, App.Courses.Course

    timestamps()
  end

  @doc false
  def changeset(semester, attrs) do
    semester
    |> cast(attrs, [:name, :term_code])
    |> validate_required([:name, :term_code])
    |> unique_constraint(:name)
  end
end
