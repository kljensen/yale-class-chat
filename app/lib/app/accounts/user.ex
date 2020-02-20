defmodule App.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :net_id, :string
    field :is_faculty, :boolean, default: false

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:net_id, :display_name, :email, :is_faculty])
    |> validate_required([:net_id, :display_name, :email, :is_faculty])
    |> unique_constraint(:net_id)
    |> validate_format(:email, ~r/@/)
  end
end
