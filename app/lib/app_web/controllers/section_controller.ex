defmodule AppWeb.SectionController do
  use AppWeb, :controller

  alias App.Courses
  alias App.Courses.Section

  def index(conn, _params) do
    sections = Courses.list_sections()
    render(conn, "index.html", sections: sections)
  end

  def new(conn, _params) do
    changeset = Courses.change_section(%Section{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"section" => section_params}) do
    case Courses.create_section(section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, "Section created successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    section = Courses.get_section!(id)
    render(conn, "show.html", section: section)
  end

  def edit(conn, %{"id" => id}) do
    section = Courses.get_section!(id)
    changeset = Courses.change_section(section)
    render(conn, "edit.html", section: section, changeset: changeset)
  end

  def update(conn, %{"id" => id, "section" => section_params}) do
    section = Courses.get_section!(id)

    case Courses.update_section(section, section_params) do
      {:ok, section} ->
        conn
        |> put_flash(:info, "Section updated successfully.")
        |> redirect(to: Routes.section_path(conn, :show, section))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", section: section, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    section = Courses.get_section!(id)
    {:ok, _section} = Courses.delete_section(section)

    conn
    |> put_flash(:info, "Section deleted successfully.")
    |> redirect(to: Routes.section_path(conn, :index))
  end
end
