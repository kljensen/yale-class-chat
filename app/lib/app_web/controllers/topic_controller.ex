defmodule AppWeb.TopicController do
  use AppWeb, :controller

  alias App.Topics
  alias App.Topics.Topic
  alias App.Courses
  alias App.Submissions

  @sort_list ["date - ascending", "date - descending", "rating - ascending", "rating - descending", "rating - ascending", "random"]

  def index(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user
    can_edit = App.Accounts.can_edit_section(user, section)

    topics = Topics.list_user_topics(user, section)
    render(conn, "index.html", topics: topics, section: section, can_edit: can_edit)
  end

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_course(user, course) do
      true ->
        changeset = Topics.change_topic(%Topic{})
        section_list = Courses.list_user_sections(course, user)
        section_map = Enum.map(section_list, fn (x) -> [x.id, x.title] end)
        sections = Enum.map(section_map, fn [value, key] -> {:"#{key}", value} end)
        selected_sections = Map.values(Map.new(sections))
        {:ok, current_time} = DateTime.now("America/New_York")
        render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end

  def create(conn, %{"topic" => topic_params, "course_id" => course_id}) do
    section_ids = Map.get(topic_params, "sections")
    user = conn.assigns.current_user
    course = Courses.get_course!(course_id)
    section_list = Courses.list_user_sections(course, user)
    section_map = Enum.map(section_list, fn (x) -> [x.id, x.title] end)
    sections = Enum.map(section_map, fn [value, key] -> {:"#{key}", value} end)
    selected_sections = Map.values(Map.new(sections))
    {:ok, current_time} = DateTime.now("America/New_York")
    opened_at_raw = topic_params["opened_at"]
    {:ok, opened_at} = NaiveDateTime.new(String.to_integer(opened_at_raw["year"]), String.to_integer(opened_at_raw["month"]), String.to_integer(opened_at_raw["day"]), String.to_integer(opened_at_raw["hour"]), String.to_integer(opened_at_raw["minute"]), 0)
    {:ok, opened_at} = DateTime.from_naive(opened_at, "America/New_York")
    {:ok, opened_at} = DateTime.shift_zone(opened_at, "Etc/UTC")

    closed_at_raw = topic_params["closed_at"]
    {:ok, closed_at} = NaiveDateTime.new(String.to_integer(closed_at_raw["year"]), String.to_integer(closed_at_raw["month"]), String.to_integer(closed_at_raw["day"]), String.to_integer(closed_at_raw["hour"]), String.to_integer(closed_at_raw["minute"]), 0)
    {:ok, closed_at} = DateTime.from_naive(closed_at, "America/New_York")
    {:ok, closed_at} = DateTime.shift_zone(closed_at, "Etc/UTC")

    topic_params = Map.put(topic_params, "opened_at", opened_at)
    topic_params = Map.put(topic_params, "closed_at", opened_at)

    case section_ids do
      nil ->
        changeset = Topics.change_topic(%Topic{})
        put_flash(conn, :error, "Must select at least one section")
        render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

      _ ->
        section_id = List.first(section_ids)
        section = Courses.get_section!(section_id)
        case Topics.create_topic(user, section, topic_params) do
          {:ok, topic} ->
            for section_id <- section_ids do
                            section_id = String.to_integer(section_id)
                            section = Courses.get_section!(section_id)
                            Topics.create_topic(user, section, topic_params)
                          end
            conn
            |> put_flash(:info, "Topic(s) created successfully.")
            |> redirect(to: Routes.topic_path(conn, :show, topic))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)

          {:error, message} ->
            changeset = Topics.change_topic(%Topic{})
            conn
            |> put_flash(:error, message)
            |> render("new.html", changeset: changeset, course: course, sections: sections, selected_sections: selected_sections, current_time: current_time, sort_list: @sort_list)
        end
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    user = conn.assigns.current_user
    can_edit = App.Accounts.can_edit_topic(user, topic)
    submissions = case topic.show_user_submissions do
      true ->
        Submissions.list_user_submissions(user, topic)
      false ->
        case can_edit do
          true ->
            Submissions.list_user_submissions(user, topic)
          false ->
            Submissions.list_user_own_submissions(user, topic)
          end
      end
    render(conn, "show.html", topic: topic, submissions: submissions, can_edit: can_edit, uid: user.id)
  end

  def edit(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_topic(user, topic) do
      true ->
        section = Courses.get_section!(topic.section_id)
        changeset = Topics.change_topic(topic)
        {:ok, current_time} = DateTime.now("America/New_York")
        render(conn, "edit.html", topic: topic, changeset: changeset, current_time: current_time, section: section, sort_list: @sort_list)

      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Topics.get_topic!(id)
    section = Courses.get_section!(topic.section_id)
    user = conn.assigns.current_user

    case Topics.update_topic(user, topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      {:error, %Ecto.Changeset{} = changeset} ->
        {:ok, current_time} = DateTime.now("America/New_York")
        render(conn, "edit.html", topic: topic, changeset: changeset, current_time: current_time, section: section, sort_list: @sort_list)

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

  def delete(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    section = Courses.get_section!(topic.section_id)
    user = conn.assigns.current_user
    {:ok, _topic} = Topics.delete_topic(user, topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: Routes.section_topic_path(conn, :index, section))
  end
end
