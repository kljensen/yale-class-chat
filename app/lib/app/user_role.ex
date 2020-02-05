defmodule App.User_role do
  use Ecto.Schema

  schema "user_roles" do
    field :role, :string
    field :valid_from, :utc_datetime
    field :valid_to, :utc_datetime
    belongs_to :section, App.Section
    belongs_to :user, App.User
  end

  def changeset(user_role, params \\ %{}) do
    user_role
    |> Ecto.Changeset.cast(params, [:role, :valid_from])
    |> Ecto.Changeset.validate_required([:role, :valid_from])
  end
end
