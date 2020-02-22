defmodule App.Accounts.Course_Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "course_roles" do
    field :role, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime

    timestamps()
  end

  @doc false
  def changeset(course__role, attrs) do
    course__role
    |> cast(attrs, [:role, :valid_from, :valid_to])
    |> validate_required([:role, :valid_from, :valid_to])
  end
end
