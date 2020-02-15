defmodule App.Course do
  use Ecto.Schema
  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    field :department, :string
    field :number, :integer
    belongs_to :semester, App.Semester

    timestamps()
  end

  @doc false
  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
