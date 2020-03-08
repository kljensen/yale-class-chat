defmodule AppWeb.CourseController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Course

  def index(conn, _params) do
    user = conn.assigns.current_user
    courses = Courses.list_user_courses(user)
    list = Courses.list_semester_names()
    semesters = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
    render(conn, "index.html", courses: courses, semesters: semesters)
  end

  def new(conn, _params) do
    changeset = Courses.change_course(%Course{})
    list = Courses.list_semester_names()
    semesters = Enum.map(list, fn [value, key] -> {:"#{key}", value} end)
    render(conn, "new.html", [changeset: changeset, semesters: semesters])
  end

  def create(conn, %{"course" => course_params}) do
    user = conn.assigns.current_user
    semester_id = Map.get(course_params, "semester_id")
    semester = Courses.get_semester!(semester_id)
    case Courses.create_course(user, semester, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course created successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        list = Courses.list_semester_names()
        semesters = Enum.map(list, fn [value, key] -> {:"#{key}", value} end)
        render(conn, "new.html", [changeset: changeset, semesters: semesters])
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_course(user, id) do
      {:ok, course} ->
        semester = Courses.get_semester!(course.semester_id)
        render(conn, "show.html", course: course, semester: semester)
      {:error, message} ->
        case message do
          "forbidden" ->
            conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
          "not found" ->
            conn
            |> put_status(:not_found)
            |> put_view(AppWeb.ErrorView)
            |> render("404.html")
        end
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_course(user, id) do
      {:ok, course} ->
        changeset = Courses.change_course(course)
        semester = Courses.get_semester!(course.semester_id)
        semesters = [{:"#{semester.name}", semester.id}]
        render(conn, "edit.html", course: course, changeset: changeset, semesters: semesters)
      {:error, message} ->
        case message do
          "forbidden" ->
            conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
          "not found" ->
            conn
            |> put_status(:not_found)
            |> put_view(AppWeb.ErrorView)
            |> render("404.html")
        end
    end
  end

  def update(conn, %{"id" => id, "course" => course_params}) do
    course = Courses.get_course!(id)
    user = conn.assigns.current_user

    case Courses.update_course(user, course, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:info, "Course updated successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        semester = Courses.get_semester!(course.semester_id)
        semesters = [{:"#{semester.name}", semester.id}]
        render(conn, "edit.html", course: course, changeset: changeset, semesters: semesters)

      {:error, message} ->
        conn
        |> put_status(:forbidden)
        |> put_view(AppWeb.ErrorView)
        |> render("403.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
    user = conn.assigns.current_user
    {:ok, _course} = Courses.delete_course(user, course)

    conn
    |> put_flash(:info, "Course deleted successfully.")
    |> redirect(to: Routes.course_path(conn, :index))
  end
end
