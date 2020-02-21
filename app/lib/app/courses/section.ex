defmodule App.Courses.Section do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sections" do
    field :crn, :string
    field :title, :string
    belongs_to :course, App.Courses.Course
    has_many :topics, App.Topics.Topic
    has_many :user_roles, App.Accounts.User_Role

    timestamps()
  end

  @doc false
  def changeset(section, attrs) do
    section
    |> cast(attrs, [:title, :crn])
    |> validate_required([:title, :crn])
    |> unique_constraint(:crn)
    |> foreign_key_constraint(:course_id)
    |> assoc_constraint(:course)
  end
end
