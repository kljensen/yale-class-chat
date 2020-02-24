defmodule App.Accounts.Section_Role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "section_roles" do
    field :role, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    belongs_to :section, App.Courses.Section
    belongs_to :user, App.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(section__role, attrs) do
    section__role
    |> cast(attrs, [:role, :valid_from, :valid_to])
    |> validate_required([:role, :valid_from, :valid_to])
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:section_id)
    |> assoc_constraint(:user)
    |> assoc_constraint(:section)
  end
end
