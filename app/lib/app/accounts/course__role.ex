defmodule App.Accounts.Course_Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_roles" do
    field :role, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    belongs_to :course, App.Courses.Course
    belongs_to :user, App.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(course__role, attrs) do
    course__role
    |> cast(attrs, [:role, :valid_from, :valid_to])
    |> validate_required([:role, :valid_from, :valid_to])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:course_id)
    |> assoc_constraint(:user)
    |> assoc_constraint(:course)
  end
end
