defmodule AppWeb.TopicController do
  use AppWeb, :controller

  alias App.Topics
  alias App.Topics.Topic
  alias App.Courses

  def index(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user

    topics = Topics.list_user_topics(user, section)
    render(conn, "index.html", topics: topics, section: section)
  end

  def new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    changeset = Topics.change_topic(%Topic{})
    render(conn, "new.html", changeset: changeset, course: course)
  end

  def create(conn, %{"topic" => topic_params}) do
    section_id = Map.get(topic_params, "section_id")
    case Topics.create_topic(topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic created successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      {:error, %Ecto.Changeset{} = changeset} ->
        section = Courses.get_section!(section_id)
        user = conn.assigns.current_user
        render(conn, "new.html", changeset: changeset, section: section)
    end
  end

  def show(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    render(conn, "show.html", topic: topic)
  end

  def edit(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    changeset = Topics.change_topic(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Topics.get_topic!(id)

    case Topics.update_topic(topic, topic_params) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "Topic updated successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Topics.get_topic!(id)
    {:ok, _topic} = Topics.delete_topic(topic)

    conn
    |> put_flash(:info, "Topic deleted successfully.")
    |> redirect(to: Routes.topic_path(conn, :index))
  end
end
