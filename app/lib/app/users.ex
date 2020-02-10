defmodule App.Users do

  alias App.Repo
  alias App.User

  def get_user!(id), do: Repo.get!(User, id)
  def get_by_netid(net_id), do: Repo.get_by(User, net_id: net_id)

  def update_user(user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update
  end

  def new(net_id, display_name, email) do
    user = %App.User{}
    changeset = App.User.changeset(user, %{net_id: net_id, display_name: display_name, email: email})

    App.Repo.insert(changeset)
    #case App.Repo.insert(changeset) do
    #  {:ok, user} ->
    #    # do something with user
    #
    #  {:error, changeset} ->
    #    # do something with changeset
    #
    #end

  end

end
