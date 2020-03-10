defmodule AppWeb.Course_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Course_Role
  alias App.Courses

  def index(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    list = Accounts.list_course__role_users(user, course)
    user_list = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
    course_roles = Accounts.list_course_all_course_roles(user, course)
    render(conn, "index.html", course_roles: course_roles, course: course, user_list: user_list)
  end

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_course__roles(user, course)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    role_list = ["administrator", "owner"]
    changeset = Accounts.change_course__role(%Course_Role{})
    render(conn, "new.html", changeset: changeset, course: course, role_list: role_list, user_list: user_list)
  end

  def create(conn, %{"course__role" => course__role_params, "course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user_auth = conn.assigns.current_user
    uid = course__role_params["user_id"]
    user = Accounts.get_user!(uid)
    net_id = user.net_id
    user = Accounts.get_user_by!(net_id)
    case Accounts.create_course__role(user_auth, user, course, course__role_params) do
      {:ok, course__role} ->
        conn
        |> put_flash(:info, "Course  role created successfully.")
        |> redirect(to: Routes.course_course__role_path(conn, :show, course_role: course__role), course: course)

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, course: course)
    end
  end

  def show(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    course = Courses.get_course!(course__role.course_id)
    render(conn, "show.html", course__role: course__role, course: course)
  end

  def edit(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    changeset = Accounts.change_course__role(course__role)
    render(conn, "edit.html", course__role: course__role, changeset: changeset)
  end

  def update(conn, %{"id" => id, "course__role" => course__role_params}) do
    course__role = Accounts.get_course__role!(id)

    case Accounts.update_course__role(course__role, course__role_params) do
      {:ok, course__role} ->
        conn
        |> put_flash(:info, "Course  role updated successfully.")
        |> redirect(to: Routes.course__role_path(conn, :show, course__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", course__role: course__role, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    {:ok, _course__role} = Accounts.delete_course__role(course__role)

    conn
    |> put_flash(:info, "Course  role deleted successfully.")
    |> redirect(to: Routes.course__role_path(conn, :index))
  end
end
