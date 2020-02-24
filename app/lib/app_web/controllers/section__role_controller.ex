defmodule AppWeb.Section_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Section_Role

  def index(conn, _params) do
    section_roles = Accounts.list_section_roles()
    render(conn, "index.html", section_roles: section_roles)
  end

  def new(conn, _params) do
    changeset = Accounts.change_section__role(%Section_Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"section__role" => section__role_params}) do
    case Accounts.create_section__role(section__role_params) do
      {:ok, section__role} ->
        conn
        |> put_flash(:info, "Section  role created successfully.")
        |> redirect(to: Routes.section__role_path(conn, :show, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    render(conn, "show.html", section__role: section__role)
  end

  def edit(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    changeset = Accounts.change_section__role(section__role)
    render(conn, "edit.html", section__role: section__role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "section__role" => section__role_params}) do
    section__role = Accounts.get_section__role!(id)

    case Accounts.update_section__role(section__role, section__role_params) do
      {:ok, section__role} ->
        conn
        |> put_flash(:info, "Section  role updated successfully.")
        |> redirect(to: Routes.section__role_path(conn, :show, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", section__role: section__role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    {:ok, _section__role} = Accounts.delete_section__role(section__role)

    conn
    |> put_flash(:info, "Section  role deleted successfully.")
    |> redirect(to: Routes.section__role_path(conn, :index))
  end
end
