defmodule AppWeb.SemesterController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Semester

  def index(conn, _params) do
    semesters = Courses.list_semesters()
    render(conn, "index.html", semesters: semesters)
  end

  def new(conn, _params) do
    changeset = Courses.change_semester(%Semester{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"semester" => semester_params}) do
    user = conn.assigns.current_user
    case Courses.create_semester(user, semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester created successfully.")
        |> redirect(to: Routes.semester_path(conn, :show, semester))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)

      {:error, error} ->
        changeset = Courses.change_semester(%Semester{})
        conn
        |> put_flash(:error, error)
        |> render("new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    semester = Courses.get_semester!(id)
    render(conn, "show.html", semester: semester)
  end

  def edit(conn, %{"id" => id}) do
    semester = Courses.get_semester!(id)
    changeset = Courses.change_semester(semester)
    render(conn, "edit.html", semester: semester, changeset: changeset)
  end

  def update(conn, %{"id" => id, "semester" => semester_params}) do
    semester = Courses.get_semester!(id)

    case Courses.update_semester(semester, semester_params) do
      {:ok, semester} ->
        conn
        |> put_flash(:info, "Semester updated successfully.")
        |> redirect(to: Routes.semester_path(conn, :show, semester))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", semester: semester, changeset: changeset)

      {:error, error} ->
        changeset = Courses.change_semester(%Semester{})
        conn
        |> put_flash(:error, error)
        |> render("new.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    semester = Courses.get_semester!(id)
    {:ok, _semester} = Courses.delete_semester(semester)

    conn
    |> put_flash(:info, "Semester deleted successfully.")
    |> redirect(to: Routes.semester_path(conn, :index))
  end
end
