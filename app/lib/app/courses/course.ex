defmodule App.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :department, :string
    field :name, :string
    field :number, :integer
    field :allow_write, :boolean
    field :allow_read, :boolean
    belongs_to :semester, App.Courses.Semester
    has_many :sections, App.Courses.Section

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :department, :number, :allow_write, :allow_read, :semester_id])
    |> validate_required([:name, :department, :number, :allow_write, :allow_read])
    |> foreign_key_constraint(:semester_id)
    |> assoc_constraint(:semester)
  end
end
