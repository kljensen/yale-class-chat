defmodule App.User_role do
  use Ecto.Schema
  import Ecto.Changeset

  schema "user_roles" do
    field :role, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    belongs_to :section, App.Section
    belongs_to :user, App.User

    timestamps()
  end

  @doc false
  def changeset(user_role, attrs) do
    user_role
    |> cast(attrs, [:role, :valid_from])
    |> validate_required([:role, :valid_from])
  end
end
