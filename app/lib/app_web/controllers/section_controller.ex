defmodule AppWeb.SectionController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Section

  def index(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    sections = Courses.list_user_sections(course, user)
    render(conn, "index.html", sections: sections, course: course)
  end

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    changeset = Courses.change_section(%Section{})
    render(conn, "new.html", changeset: changeset, course: course)
  end

  def create(conn, %{"section" => section_params}) do
    user = conn.assigns.current_user
    course_id = semester_id = Map.get(section_params, "course_id")
    course = Courses.get_course!(course_id)
    case Courses.create_section(user, course, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, "Section created successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, course: course)
    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_section(user, id) do
      {:ok, section} ->
        render(conn, "show.html", section: section)
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
    case Courses.get_user_section(user, id) do
      {:ok, section} ->
        section = Courses.get_section!(id)
        course = Courses.get_course!(section.course_id)
        changeset = Courses.change_section(section)
        render(conn, "edit.html", section: section, changeset: changeset, course: course)
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

  def update(conn, %{"id" => id, "section" => section_params}) do
    section = Courses.get_section!(id)
    user = conn.assigns.current_user

    case Courses.update_section(user, section, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, "Section updated successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        course = Courses.get_course!(section.course_id)
        render(conn, "edit.html", section: section, changeset: changeset, course: course)
    end
  end

  def delete(conn, %{"id" => id}) do
    section = Courses.get_section!(id)
    cid = section.course_id
    user = conn.assigns.current_user
    {:ok, _section} = Courses.delete_section(user, section)

    conn
    |> put_flash(:info, "Section deleted successfully.")
    |> redirect(to: Routes.course_section_path(conn, :index, cid))
  end
end
