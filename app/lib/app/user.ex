defmodule App.User do
  use Ecto.Schema

  schema "users" do
    field :net_id, :string
    field :display_name, :string
    field :email, :string
  end

  def changeset(user, params \\ %{}) do
    user
    |> Ecto.Changeset.cast(params, [:net_id, :email])
    |> Ecto.Changeset.validate_required([:net_id])
    |> Ecto.Changeset.unsafe_validate_unique([:net_id], App.Repo, message: "net id is already in use")
    |> Ecto.Changeset.unique_constraint(:net_id)
    |> Ecto.Changeset.validate_format(:email, ~r/@/)
    # do we need to ensure emails are also unique?
  end
end
