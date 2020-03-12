defmodule AppWeb.Course_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Course_Role
  alias App.Courses

  @course_admin_roles ["administrator", "owner"]

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
    changeset = Accounts.change_course__role(%Course_Role{})
    render(conn, "new.html", changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)
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
        |> redirect(to: Routes.course_course__role_path(conn, :show, course, course__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        list = Accounts.list_users_for_course__roles(user_auth, course)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "new.html", changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)

      {:error, message} ->
        list = Accounts.list_users_for_course__roles(user_auth, course)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        changeset = Accounts.change_course__role(%Course_Role{})
        conn
        |> put_flash(:error, message)
        |> render("new.html", changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)
    end
  end

  def show(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    course = Courses.get_course!(course__role.course_id)
    render(conn, "show.html", course__role: course__role, course: course)
  end

  def edit(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(String.to_integer(id))
    course = Courses.get_course!(course__role.course_id)
    changeset = Accounts.change_course__role(course__role)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_course__roles(user, course)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    render(conn, "edit.html", course__role: course__role, changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)
  end

  def update(conn, %{"id" => id, "course__role" => course__role_params}) do
    course__role = Accounts.get_course__role!(id)
    user = conn.assigns.current_user

    case Accounts.update_course__role(user, course__role, course__role_params) do
      {:ok, course__role} ->
        course = Courses.get_course!(course__role.course_id)
        conn
        |> put_flash(:info, "Course  role updated successfully.")
        |> redirect(to: Routes.course_course__role_path(conn, :show, course, course__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        course__role = Accounts.get_course__role!(String.to_integer(id))
        course = Courses.get_course!(course__role.course_id)
        changeset = Accounts.change_course__role(course__role)
        list = Accounts.list_users_for_course__roles(user, course)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "edit.html", course__role: course__role, changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)
    end
  end

  def delete(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    course = Courses.get_course!(course__role.course_id)
    user = conn.assigns.current_user
    {:ok, _course__role} = Accounts.delete_course__role(user, course__role)

    conn
    |> put_flash(:info, "Course  role deleted successfully.")
    |> redirect(to: Routes.course_course__role_path(conn, :index, course))
  end
end
