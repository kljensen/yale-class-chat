defmodule AppWeb.TopicController do
  use AppWeb, :controller

  alias App.Topics
  alias App.Topics.Topic
  alias App.Courses
  alias App.Submissions
  alias Phoenix.LiveView


  @sort_list ["date - ascending", "date - descending", "rating - ascending", "rating - descending", "rating - ascending", "random"]

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit(user, course.id, "course") do
      true ->
        changeset = Topics.change_topic(%Topic{})
        section_list = Courses.list_user_sections(course, user)
        section_map = Enum.map(section_list, fn (x) -> [x.id, x.title] end)
        sections = Enum.map(section_map, fn [value, key] -> {:"#{key}", value} end)
        selected_sections = Map.values(Map.new(sections))
        current_time = current_html_time()
        render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

      false -> render_error(conn, "forbidden")
      end
  end

  def create(conn, %{"topic" => topic_params, "course_id" => course_id}) do
    section_ids = Map.get(topic_params, "sections")
    user = conn.assigns.current_user
    case Courses.get_user_course(user, course_id) do
      {:ok, course} ->
        section_list = Courses.list_user_sections(course, user)
        section_map = Enum.map(section_list, fn (x) -> [x.id, x.title] end)
        sections = Enum.map(section_map, fn [value, key] -> {:"#{key}", value} end)
        selected_sections = Map.values(Map.new(sections))
        current_time = current_html_time()
        topic_params = Map.put(topic_params, "opened_at", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(topic_params["opened_at"]))
        topic_params = Map.put(topic_params, "closed_at", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(topic_params["closed_at"]))

        case section_ids do
          nil ->
            changeset = Topics.change_topic(%Topic{})
            put_flash(conn, :error, "Must select at least one section")
            render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

          _ ->
            {section_id, section_ids} = List.pop_at(section_ids, 0)
            section = Courses.get_section!(section_id)
            case Topics.create_topic!(user, section, topic_params) do
              {:ok, topic} ->
                if length(section_ids) > 0 do
                  for section_id <- section_ids do
                    section_id = String.to_integer(section_id)
                    section = Courses.get_section!(section_id)
                    Topics.create_topic!(user, section, topic_params)
                  end
                end
                conn
                |> put_flash(:success, "Topic(s) created successfully.")
                |> redirect(to: Routes.topic_path(conn, :show, topic))

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

              {:error, message} -> render_error(conn, message)
            end
        end

      {:error, message} -> render_error(conn, message)
      end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    # TODO: notice I'm pulling in data multiple times here. Should
    # Fix this. Most of these controllers need to be refactored.
    case Topics.user_can_view_topic(user, id) do
      {:ok, topic} ->
        topic_data = App.Topics.get_topic_data_for_user_id(user.id, id)
        render(conn, "show.html", topic_data)
      {:error, message} -> render_error(conn, message)
      end
  end

  def edit(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Topics.get_user_topic(user, id) do
      {:ok, topic} ->
        section = topic.section
        course = section.course
        case App.Accounts.can_edit(user, topic.id, "topic") do
          true ->
            changeset = Topics.change_topic(topic)
            current_time = current_html_time()
            render(conn, "edit.html", topic: topic, changeset: changeset, current_time: current_time, section: section, sort_list: @sort_list, section: section, course: course)

          false -> render_error(conn, "forbidden")
          end

        {:error, message} -> render_error(conn, message)
        end
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    user = conn.assigns.current_user
    {:ok, topic} = Topics.get_user_topic(user, id)
    section = topic.section
    user = conn.assigns.current_user
    current_time = current_html_time()
    topic_params = Map.put(topic_params, "opened_at", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(topic_params["opened_at"]))
    topic_params = Map.put(topic_params, "closed_at", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(topic_params["closed_at"]))

    case Topics.update_topic!(user, topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:success, "Topic updated successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      {:error, %Ecto.Changeset{} = changeset} ->
        current_time = current_html_time()
        render(conn, "edit.html", topic: topic, changeset: changeset, current_time: current_time, section: section, sort_list: @sort_list, course: section.course)

      {:error, message} -> render_error(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Topics.get_user_topic(user, id) do
      {:ok, topic} ->
        user = conn.assigns.current_user
        {:ok, _topic} = Topics.delete_topic!(user, topic)

        conn
        |> put_flash(:success, "Topic deleted successfully.")
        |> redirect(to: Routes.section_path(conn, :show, topic.section))

      {:error, message} -> render_error(conn, message)
      end
  end
end
