defmodule App.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :net_id, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:net_id, :display_name, :email])
    |> validate_required([:net_id, :display_name, :email])
    |> unique_constraint(:net_id)
    |> validate_format(:email, ~r/@/)
  end
end
