defmodule App.Topics do
  @moduledoc """
  The Topics context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Topics.Topic

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
    allowed_section_roles = ["student", "defunct_student", "guest"]
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
      allowed_course_roles = ["administrator", "owner"]
      auth_role = App.Accounts.get_current_course__role(user, course)
      if Enum.member?(allowed_course_roles, auth_role) do
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

  @doc """
  Creates a topic.

  ## Examples

      iex> create_topic(%{field: value})
      {:ok, %Topic{}}

      iex> create_topic(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_topic(%App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs \\ %{}) do
    allowed_roles = ["administrator", "owner"]
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_topic(section, attrs)
    end
  end

  defp do_create_topic(%App.Courses.Section{} = section, attrs \\ %{}) do
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
    allowed_roles = ["administrator", "owner"]
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
    allowed_roles = ["administrator", "owner"]
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
