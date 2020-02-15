defmodule AppWeb.User_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.User_Role

  def index(conn, _params) do
    user_roles = Accounts.list_user_roles()
    render(conn, "index.html", user_roles: user_roles)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user__role(%User_Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user__role" => user__role_params}) do
    case Accounts.create_user__role(user__role_params) do
      {:ok, user__role} ->
        conn
        |> put_flash(:info, "User  role created successfully.")
        |> redirect(to: Routes.user__role_path(conn, :show, user__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    user__role = Accounts.get_user__role!(id)
    render(conn, "show.html", user__role: user__role)
  end

  def edit(conn, %{"id" => id}) do
    user__role = Accounts.get_user__role!(id)
    changeset = Accounts.change_user__role(user__role)
    render(conn, "edit.html", user__role: user__role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user__role" => user__role_params}) do
    user__role = Accounts.get_user__role!(id)

    case Accounts.update_user__role(user__role, user__role_params) do
      {:ok, user__role} ->
        conn
        |> put_flash(:info, "User  role updated successfully.")
        |> redirect(to: Routes.user__role_path(conn, :show, user__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user__role: user__role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user__role = Accounts.get_user__role!(id)
    {:ok, _user__role} = Accounts.delete_user__role(user__role)

    conn
    |> put_flash(:info, "User  role deleted successfully.")
    |> redirect(to: Routes.user__role_path(conn, :index))
  end
end
