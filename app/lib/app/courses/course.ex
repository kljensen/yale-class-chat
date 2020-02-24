defmodule App.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :department, :string
    field :name, :string
    field :number, :integer
    belongs_to :semester, App.Courses.Semester
    has_many :sections, App.Courses.Section

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :department, :number])
    |> validate_required([:name, :department, :number])
    |> foreign_key_constraint(:semester_id)
    |> assoc_constraint(:semester)
  end
end