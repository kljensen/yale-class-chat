defmodule App.Topics do
  @course_owner_roles ["owner"]
  @course_admin_roles ["administrator", "owner"]
  @section_write_roles ["student"]
  @section_read_roles ["student", "defunct_student", "guest"]
  require Logger

  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias App.Repo
  alias App.Accounts.User
  alias App.Topics.Topic
  alias App.Submissions

  @doc """
  Returns the list of topics.

  ## Examples

      iex> list_topics()
      [%Topic{}, ...]

  """
  def list_topics do
    Repo.all(Topic)
  end

  @doc """
  Returns the list of topics for a given section.

  ## Examples

      iex> list_topics(section)
      [%Topic{}, ...]

  """
  def list_topics(%App.Courses.Section{} = section) do
    sid = section.id
    query = from t in Topic,
              where: t.section_id == ^sid,
              select: t
    Repo.all(query)
  end

  @doc """
  Returns the list of topics a user can see for a given section.

  ## Examples

      iex> list_user_topics(section)
      [%Topic{}, ...]

  """
  def list_user_topics(%App.Accounts.User{} = user, %App.Courses.Section{} = section, inherit_course_role \\ true) do
    sid = section.id
    uid = user.id
    cid = section.course_id
    allowed_section_roles = @section_read_roles
    query = from r in App.Accounts.Section_Role,
              join: s in App.Courses.Section,
              on: r.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: t in Topic,
              on: t.section_id == s.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: s.id == ^sid,
              where: t.visible,
              select: t

    query = if inherit_course_role do
      course = App.Courses.get_course!(cid)
      auth_role = App.Accounts.get_current_course__role(user, course)
      if Enum.member?(@course_admin_roles, auth_role) do
        from t in Topic,
          where: t.section_id == ^sid,
          select: t
      else
        query
      end
    else
      query
    end
    Repo.all(query)
  end

  # TODO: clean up these methods. Notice that these
  # are making two database round trips. We should be
  # able to make a query that takes either net_id or
  # id and get the same result in a single trip.
  def get_topic_data_for_user_id(user_id, topic_id) do
    user = App.Accounts.get_user!(user_id)
    get_topic_data_for_user(user, topic_id)
  end
  def get_topic_data_for_net_id(net_id, topic_id) do
    user = Repo.get_by!(User, net_id: net_id)
    get_topic_data_for_user(user, topic_id)
  end

  def get_topic_data_for_user(user, topic_id) do
    topic = get_with_couse_and_section(topic_id)
    can_edit = App.Accounts.can_edit_topic(user, topic)
    section = topic.section
    course = topic.section.course
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
    %{topic: topic, submissions: submissions, can_edit: can_edit, uid: user.id, section: section, course: course}
  end


  @doc """
  Gets a single topic.

  Raises `Ecto.NoResultsError` if the Topic does not exist.

  ## Examples

      iex> get_topic!(123)
      %Topic{}

      iex> get_topic!(456)
      ** (Ecto.NoResultsError)

  """
  def get_topic!(id), do: Repo.get!(Topic, id)

  def user_can_view_topic(%App.Accounts.User{} = user, topic_id) do
    get_user_topic(user, topic_id)
  end

  def get_with_couse_and_section(id) do
    query = from t in Topic,
              where: t.id == ^id,
              left_join: s in assoc(t, :section),
              on: t.section_id == s.id,
              left_join: c in assoc(s, :course),
              on: s.course_id == c.id,
              select: t
    query
    |> preload([t, s, c], [section: {s, course: c}])
    |> Repo.one()
  end

  def get_user_topic(%App.Accounts.User{} = user, topic_id) do
    allowed_course_roles = @course_admin_roles
    uid = user.id
    result = get_with_couse_and_section(topic_id)

    if is_nil(result) do
      query = from t in Topic, where: t.id == ^topic_id
      message = if Repo.exists?(query) do
                  "forbidden"
                else
                  "not found"
                end
      {:error, message}
    else
      {:ok, result}
    end
  end

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(%App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs \\ %{}) do
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_topic(section, attrs)
    end
  end

  defp do_create_topic(%App.Courses.Section{} = section, attrs) do
    %Topic{}
    |> Topic.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:section, section)
    |> Repo.insert()
  end

  @doc """
  Updates a topic.

  ## Examples

      iex> update_topic(topic, %{field: new_value})
      {:ok, %Topic{}}

      iex> update_topic(topic, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_topic(%App.Accounts.User{} = user, %Topic{} = topic, attrs \\ %{}) do
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_update_topic(topic, attrs)
    end
  end

  defp do_update_topic(%Topic{} = topic, attrs) do
    topic
    |> Topic.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a topic.

  ## Examples

      iex> delete_topic(topic)
      {:ok, %Topic{}}

      iex> delete_topic(topic)
      {:error, %Ecto.Changeset{}}

  """
  def delete_topic(%App.Accounts.User{} = user, %Topic{} = topic) do
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_delete_topic(topic)
    end
  end

  defp do_delete_topic(%Topic{} = topic) do
    Repo.delete(topic)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking topic changes.

  ## Examples

      iex> change_topic(topic)
      %Ecto.Changeset{source: %Topic{}}

  """
  def change_topic(%Topic{} = topic) do
    Topic.changeset(topic, %{})
  end
end
