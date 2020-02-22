defmodule AppWeb.Course_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Course_Role

  def index(conn, _params) do
    course_roles = Accounts.list_course_roles()
    render(conn, "index.html", course_roles: course_roles)
  end

  def new(conn, _params) do
    changeset = Accounts.change_course__role(%Course_Role{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"course__role" => course__role_params}) do
    case Accounts.create_course__role(course__role_params) do
      {:ok, course__role} ->
        conn
        |> put_flash(:info, "Course  role created successfully.")
        |> redirect(to: Routes.course__role_path(conn, :show, course__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    render(conn, "show.html", course__role: course__role)
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
