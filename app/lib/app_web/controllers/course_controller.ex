defmodule AppWeb.CourseController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Course

  def index(conn, _params) do
    user = conn.assigns.current_user
    case user.is_faculty do
      true ->
        courses = Courses.list_user_courses(user)
        list = Courses.list_semester_names()
        semesters = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
        render(conn, "index.html", courses: courses, semesters: semesters)
      false -> render_error(conn, "forbidden")
      end
  end

  def new(conn, _params) do
    user = conn.assigns.current_user
    case user.is_faculty do
      true ->
        changeset = Courses.change_course(%Course{})
        list = Courses.list_semester_names()
        semesters = Enum.map(list, fn [value, key] -> {:"#{key}", value} end)
        render(conn, "new.html", [changeset: changeset, semesters: semesters])
      false -> render_error(conn, "forbidden")
      end
  end

  def create(conn, %{"course" => course_params}) do
    user = conn.assigns.current_user
    semester_id = Map.get(course_params, "semester_id")
    semester = Courses.get_semester!(semester_id)
    case Courses.create_course(user, semester, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:success, "Course created successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        list = Courses.list_semester_names()
        semesters = Enum.map(list, fn [value, key] -> {:"#{key}", value} end)
        render(conn, "new.html", [changeset: changeset, semesters: semesters])

      {:error, message} -> render_error(conn, message)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_course(user, id) do
      {:ok, course} ->
        semester = Courses.get_semester!(course.semester_id)
        user = conn.assigns.current_user
        sections = Courses.list_user_sections(course, user)
        role = App.Accounts.get_current_course__role(user, course)

        render(conn, "show.html", course: course, semester: semester, sections: sections, role: role)
      {:error, message} -> render_error(conn, message)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_course(user, id) do
      {:ok, course} ->
        changeset = Courses.change_course(course)
        list = Courses.list_semester_names()
        semesters = Enum.map(list, fn [value, key] -> {:"#{key}", value} end)
        render(conn, "edit.html", course: course, changeset: changeset, semesters: semesters)
      {:error, message} -> render_error(conn, message)
    end
  end

  def update(conn, %{"id" => id, "course" => course_params}) do
    course = Courses.get_course!(id)
    user = conn.assigns.current_user

    case Courses.update_course(user, course, course_params) do
      {:ok, course} ->
        conn
        |> put_flash(:success, "Course updated successfully.")
        |> redirect(to: Routes.course_path(conn, :show, course))

      {:error, %Ecto.Changeset{} = changeset} ->
        semester = Courses.get_semester!(course.semester_id)
        semesters = [{:"#{semester.name}", semester.id}]
        render(conn, "edit.html", course: course, changeset: changeset, semesters: semesters)

      {:error, message} -> render_error(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    course = Courses.get_course!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_course(user, course) do
      true ->
        {:ok, _course} = Courses.delete_course(user, course)
        conn
        |> put_flash(:success, "Course deleted successfully.")
        |> redirect(to: Routes.course_path(conn, :index))

      false -> render_error(conn, "forbidden")
      end
  end
end
