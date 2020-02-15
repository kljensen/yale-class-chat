defmodule App.Courses.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :department, :string
    field :name, :string
    field :number, :integer

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :department, :number])
    |> validate_required([:name, :department, :number])
  end
end
