defmodule App.Courses.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sections" do
    field :crn, :string
    field :title, :string
    belongs_to :course, App.Courses.Course
    has_many :topics, App.Topics.Topic
    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :crn])
    |> validate_required([:title, :crn])
    |> unique_constraint(:crn)
  end
end
