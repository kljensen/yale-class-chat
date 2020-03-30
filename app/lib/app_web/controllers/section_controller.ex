defmodule AppWeb.SectionController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Section
  alias App.Topics
  import Phoenix.HTML.Link

  def index(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    sections = Courses.list_user_sections(course, user)
    can_edit = App.Accounts.can_edit_course(user, course)
    render(conn, "index.html", sections: sections, course: course, can_edit: can_edit)
  end

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_course(user, course) do
      true ->
        changeset = Courses.change_section(%Section{})
        render(conn, "new.html", changeset: changeset, course: course)
      false -> render_error(conn, "forbidden")
    end
  end

  def create(conn, %{"section" => section_params}) do
    user = conn.assigns.current_user
    course_id = Map.get(section_params, "course_id")
    course = Courses.get_course!(course_id)
    case Courses.create_section(user, course, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, ["Want to create another section in this course? Click ", link("here", to: Routes.course_section_path(conn, :new, course)), "!"])
        |> put_flash(:success, "Section created successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, course: course)

      {:error, message} -> render_error(conn, message)
      end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_section(user, id) do
      {:ok, section} ->
        course = section.course
        topics = Topics.list_user_topics!(user, section)
        can_edit = App.Accounts.can_edit_section(user, section)
        render(conn, "show.html", course: course, section: section, topics: topics, can_edit: can_edit)
      {:error, message} -> render_error(conn, message)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Courses.get_user_section(user, id) do
      {:ok, section} ->
        case App.Accounts.can_edit_section(user, section) do
          true ->
            course = section.course
            changeset = Courses.change_section(section)
            render(conn, "edit.html", section: section, changeset: changeset, course: course)
          false -> render_error(conn, "forbidden")
        end
      {:error, message} -> render_error(conn, message)
    end
  end

  def update(conn, %{"id" => id, "section" => section_params}) do
    user = conn.assigns.current_user
    {:ok, section} = Courses.get_user_section(user, id)

    case Courses.update_section!(user, section, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:success, "Section updated successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        course = section.course
        render(conn, "edit.html", section: section, changeset: changeset, course: course)

      {:error, message} -> render_error(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    {:ok, section} = Courses.get_user_section(user, id)
    cid = section.course_id

    case App.Accounts.can_edit_section(user, section) do
      true ->
        {:ok, _section} = Courses.delete_section!(user, section)
        conn
        |> put_flash(:success, "Section deleted successfully.")
        |> redirect(to: Routes.course_path(conn, :show, cid))

      false -> render_error(conn, "forbidden")
      end
  end
end
