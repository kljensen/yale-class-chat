defmodule AppWeb.Section_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Section_Role
  alias App.Courses

  def index(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user
    list = Accounts.list_section__role_users(user, section)
    user_list = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
    section_roles = Accounts.list_section_all_section_roles(user, section)
    render(conn, "index.html", section_roles: section_roles, section: section, user_list: user_list)
  end

  def new(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_section__roles(user, section)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    role_list = ["administrator", "owner"]
    changeset = Accounts.change_section__role(%Section_Role{})
    render(conn, "new.html", changeset: changeset, section: section, role_list: role_list, user_list: user_list)
  end

  def create(conn, %{"section__role" => section__role_params, "section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user_auth = conn.assigns.current_user
    uid = section__role_params["user_id"]
    user = Accounts.get_user!(uid)
    net_id = user.net_id
    user = Accounts.get_user_by!(net_id)
    case Accounts.create_section__role(user_auth, user, section, section__role_params) do
      {:ok, section__role} ->
        conn
        |> put_flash(:info, "Section  role created successfully.")
        |> redirect(to: Routes.section_section__role_path(conn, :show, section, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        list = Accounts.list_users_for_section__roles(user_auth, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        role_list = ["administrator", "owner"]
        render(conn, "new.html", changeset: changeset, section: section, role_list: role_list, user_list: user_list)

      {:error, message} ->
        list = Accounts.list_users_for_section__roles(user_auth, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        role_list = ["administrator", "owner"]
        changeset = Accounts.change_section__role(%Section_Role{})
        conn
        |> put_flash(:error, message)
        |> render("new.html", changeset: changeset, section: section, role_list: role_list, user_list: user_list)
    end
  end

  def show(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    section = Courses.get_section!(section__role.section_id)
    render(conn, "show.html", section__role: section__role, section: section)
  end

  def edit(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(String.to_integer(id))
    section = Courses.get_section!(section__role.section_id)
    changeset = Accounts.change_section__role(section__role)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_section__roles(user, section)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    role_list = ["administrator", "owner"]
    render(conn, "edit.html", section__role: section__role, changeset: changeset, section: section, role_list: role_list, user_list: user_list)
  end

  def update(conn, %{"id" => id, "section__role" => section__role_params}) do
    section__role = Accounts.get_section__role!(id)
    user = conn.assigns.current_user

    case Accounts.update_section__role(user, section__role, section__role_params) do
      {:ok, section__role} ->
        section = Courses.get_section!(section__role.section_id)
        conn
        |> put_flash(:info, "Section  role updated successfully.")
        |> redirect(to: Routes.section_section__role_path(conn, :show, section, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        section__role = Accounts.get_section__role!(String.to_integer(id))
        section = Courses.get_section!(section__role.section_id)
        changeset = Accounts.change_section__role(section__role)
        list = Accounts.list_users_for_section__roles(user, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        role_list = ["administrator", "owner"]
        render(conn, "edit.html", section__role: section__role, changeset: changeset, section: section, role_list: role_list, user_list: user_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    section = Courses.get_section!(section__role.section_id)
    user = conn.assigns.current_user
    {:ok, _section__role} = Accounts.delete_section__role(user, section__role)

    conn
    |> put_flash(:info, "Section  role deleted successfully.")
    |> redirect(to: Routes.section_section__role_path(conn, :index, section))
  end
end
