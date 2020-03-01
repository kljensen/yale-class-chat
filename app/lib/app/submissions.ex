defmodule App.Submissions do
  @moduledoc """
  The Submissions context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Submissions.Submission

  @doc """
  Returns the list of submissions.

  ## Examples

      iex> list_submissions()
      [%Submission{}, ...]

  """
  def list_submissions do
    Repo.all(Submission)
  end

  @doc """
  Returns the list of submissions for a given topic.

  ## Examples

      iex> list_submissions(topic)
      [%Submission{}, ...]

  """
  def list_submissions(%App.Topics.Topic{} = topic) do
    tid = topic.id
    Repo.all(from s in Submission, where: s.topic_id == ^tid)
  end

  @doc """
  Returns the list of submissions visible to a given user for a given topic.

  ## Examples

      iex> list_user_submissions(user, topic)
      [%Submission{}, ...]

  """
  def list_user_submissions(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, inherit_course_role \\ true) do
    tid = topic.id
    uid = user.id
    sid = topic.section_id
    allowed_section_roles = ["student", "defunct_student", "guest"]

    query = from r in App.Accounts.Section_Role,
              join: s in App.Courses.Section,
              on: r.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: t in App.Topics.Topic,
              on: t.section_id == s.id,
              join: su in Submission,
              on: su.topic_id == t.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: s.id == ^sid,
              where: t.visible,
              where: t.show_user_submissions,
              where: su.visible,
              where: t.id == ^tid,
              select: su

    query = if inherit_course_role do
      section = App.Courses.get_section!(sid)
      course = App.Courses.get_course!(section.course_id)
      allowed_course_roles = ["administrator", "owner"]
      auth_role = App.Accounts.get_current_course__role(user, course)
      if Enum.member?(allowed_course_roles, auth_role) do
        from s in Submission,
          where: s.topic_id == ^tid
      else
        query
      end
    else
      query
    end

    Repo.all(query)
  end

  @doc """
  Returns the list of submissions by a given user.

  ## Examples

      iex> list_user_own_submissions(user)
      [%Submission{}, ...]

  """
  def list_user_own_submissions(%App.Accounts.User{} = user) do
    uid = user.id
    Repo.all(from s in Submission, where: s.user_id == ^uid)
  end

  @doc """
  Returns the list of submissions by a given user for a given topic.

  ## Examples

      iex> list_user_own_submissions(user, topic)
      [%Submission{}, ...]

  """
  def list_user_own_submissions(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic) do
    tid = topic.id
    uid = user.id
    Repo.all(from s in Submission, where: s.topic_id == ^tid, where: s.user_id == ^uid)
  end

  @doc """
  Returns the count of submissions by a given user for a given topic.

  ## Examples

      iex> count_user_submissions(user, topic)
      [%Submission{}, ...]

  """
  def count_user_submissions(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic) do
    tid = topic.id
    uid = user.id
    Repo.all(from s in Submission, where: s.topic_id == ^tid, where: s.user_id == ^uid, select: count(s.id))
  end

  @doc """
  Gets a single submission.

  Raises `Ecto.NoResultsError` if the Submission does not exist.

  ## Examples

      iex> get_submission!(123)
      %Submission{}

      iex> get_submission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_submission!(id), do: Repo.get!(Submission, id)

  @doc """
  Creates a submission.

  ## Examples

      iex> create_submission(%{field: value})
      {:ok, %Submission{}}

      iex> create_submission(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_submission(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, attrs \\ %{}) do
    allowed_roles = ["administrator", "owner", "student"]
    admin_roles = ["administrator", "owner"]
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    #Only allow admins to hide/unhide submissions or allow them to be ranked
    unless Enum.member?(admin_roles, auth_role) do
      if Map.get(attrs, :hidden), do: attrs = Map.delete(attrs, :hidden)
      if Map.get(attrs, :allow_ranking), do: attrs = Map.delete(attrs, :allow_ranking)
    end

    cond do
      count_user_submissions(user, topic) >= [topic.user_submission_limit] ->
        {:error, "user submission limit reached"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      topic.allow_submissions == false ->
        {:error, "creating submissions not allowed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_create_submission(user, topic, attrs)
    end
  end

  defp do_create_submission(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, attrs \\ %{}) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, topic)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a submission.

  ## Examples

      iex> update_submission(submission, %{field: new_value})
      {:ok, %Submission{}}

      iex> update_submission(submission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_submission(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    admin_roles = ["administrator", "owner"]
    auth_role = App.Accounts.get_current_course__role(user, course)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    authorized = Enum.member?(admin_roles, auth_role) or user.id == submission.user_id

    #Only allow admins to hide/unhide submissions or allow them to be ranked
    unless Enum.member?(admin_roles, auth_role) do
      if Map.get(attrs, :visible), do: attrs = Map.delete(attrs, :visible)
      if Map.get(attrs, :allow_ranking), do: attrs = Map.delete(attrs, :allow_ranking)
    end

    cond do
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      topic.allow_submissions == false ->
        {:error, "updating submissions not allowed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      authorized == false ->
        {:error, "unauthorized"}
      true ->
        do_update_submission(submission, attrs)
    end
  end

  defp do_update_submission(%Submission{} = submission, attrs) do
    submission
    |> Submission.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a submission.

  ## Examples

      iex> delete_submission(submission)
      {:ok, %Submission{}}

      iex> delete_submission(submission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_submission(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    admin_roles = ["administrator", "owner"]
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    authorized = Enum.member?(admin_roles, auth_role) or user.id == submission.user_id

    cond do
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      topic.allow_submissions == false ->
        {:error, "deleting submissions not allowed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      authorized == false ->
        {:error, "unauthorized"}#
      true ->
        do_delete_submission(submission)
    end
  end

  defp do_delete_submission(%Submission{} = submission) do
    Repo.delete(submission)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking submission changes.

  ## Examples

      iex> change_submission(submission)
      %Ecto.Changeset{source: %Submission{}}

  """
  def change_submission(%Submission{} = submission) do
    Submission.changeset(submission, %{})
  end

  alias App.Submissions.Comment

  @doc """
  Returns the list of comments.

  ## Examples

      iex> list_comments()
      [%Comment{}, ...]

  """
  def list_comments do
    Repo.all(Comment)
  end

  @doc """
  Returns the list of comments for a given submission.

  ## Examples

      iex> list_comments(submission)
      [%Comment{}, ...]

  """
  def list_comments(%Submission{} = submission) do
    suid = submission.id
    Repo.all(from c in Comment, where: c.submission_id == ^suid)
  end

  @doc """
  Returns the list of comments visible to a given user for a given submission.

  ## Examples

      iex> list_user_comments(user, submission)
      [%Comment{}, ...]

  """
  def list_user_comments(%App.Accounts.User{} = user, %Submission{} = submission, inherit_course_role \\ true) do
    tid = submission.topic_id
    topic = App.Topics.get_topic!(tid)
    uid = user.id
    sid = topic.section_id
    suid = submission.id
    allowed_section_roles = ["student", "defunct_student", "guest"]

    query = from r in App.Accounts.Section_Role,
              join: s in App.Courses.Section,
              on: r.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: t in App.Topics.Topic,
              on: t.section_id == s.id,
              join: su in Submission,
              on: su.topic_id == t.id,
              join: co in Comment,
              on: co.submission_id == su.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: t.visible,
              where: t.show_user_comments,
              where: su.visible,
              where: su.id == ^suid,
              select: co

    query = if inherit_course_role do
      section = App.Courses.get_section!(sid)
      course = App.Courses.get_course!(section.course_id)
      allowed_course_roles = ["administrator", "owner"]
      auth_role = App.Accounts.get_current_course__role(user, course)
      if Enum.member?(allowed_course_roles, auth_role) do
        from co in Comment,
          where: co.submission_id == ^suid
      else
        query
      end
    else
      query
    end

    Repo.all(query)
  end

  @doc """
  Returns the list of comments by a given user.

  ## Examples

      iex> list_user_own_comments(user)
      [%Comment{}, ...]

  """
  def list_user_own_comments(%App.Accounts.User{} = user) do
    uid = user.id
    Repo.all(from co in Comment, where: co.user_id == ^uid)
  end

  @doc """
  Returns the list of comments by a given user for a given submission.

  ## Examples

      iex> list_user_own_comments(user, submission)
      [%Comment{}, ...]

  """
  def list_user_own_comments(%App.Accounts.User{} = user, %Submission{} = submission) do
    suid = submission.id
    uid = user.id
    Repo.all(from co in Comment, where: co.submission_id == ^suid, where: co.user_id == ^uid)
  end

  @doc """
  Gets a single comment.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_comment!(id), do: Repo.get!(Comment, id)

  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    allowed_roles = ["student"]
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_comments == false ->
        {:error, "commenting not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_comment(user, submission, attrs)
    end
  end

  defp do_create_comment(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:submission, submission)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment, attrs \\ %{}) do
    submission = get_submission!(comment.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_comments == false ->
        {:error, "commenting not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      user.id != comment.user_id ->
        {:error, "unauthorized"}
      true ->
        do_update_comment(comment, attrs)
    end
  end

  defp do_update_comment(%Comment{} = comment, attrs) do
    comment
    |> Comment.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a comment.

  ## Examples

      iex> delete_comment(comment)
      {:ok, %Comment{}}

      iex> delete_comment(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment) do
    submission = get_submission!(comment.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_comments == false ->
        {:error, "commenting not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      user.id != comment.user_id ->
        {:error, "unauthorized"}
      true ->
        do_delete_comment(comment)
    end
  end

  defp do_delete_comment(%Comment{} = comment) do
    Repo.delete(comment)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking comment changes.

  ## Examples

      iex> change_comment(comment)
      %Ecto.Changeset{source: %Comment{}}

  """
  def change_comment(%Comment{} = comment) do
    Comment.changeset(comment, %{})
  end

  alias App.Submissions.Rating

  @doc """
  Returns the list of ratings.

  ## Examples

      iex> list_ratings()
      [%Rating{}, ...]

  """
  def list_ratings do
    Repo.all(Rating)
  end

  @doc """
  Gets a single rating.

  Raises `Ecto.NoResultsError` if the Rating does not exist.

  ## Examples

      iex> get_rating!(123)
      %Rating{}

      iex> get_rating!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rating!(id), do: Repo.get!(Rating, id)

  @doc """
  Creates a rating.

  ## Examples

      iex> create_rating(%{field: value})
      {:ok, %Rating{}}

      iex> create_rating(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rating(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    allowed_roles = ["student"]
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_voting == false ->
        {:error, "rating not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_create_rating(user, submission, attrs)
    end
  end

  defp do_create_rating(user, submission, attrs \\ %{}) do
    %Rating{}
    |> Rating.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:submission, submission)
    |> Repo.insert()
  end

  @doc """
  Updates a rating.

  ## Examples

      iex> update_rating(rating, %{field: new_value})
      {:ok, %Rating{}}

      iex> update_rating(rating, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rating(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating, attrs \\ %{}) do
    allowed_roles = ["student"]
    submission = get_submission!(rating.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_voting == false ->
        {:error, "rating not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_update_rating(rating, attrs)
    end
  end

  defp do_update_rating(%Rating{} = rating, attrs) do
    rating
    |> Rating.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a rating.

  ## Examples

      iex> delete_rating(rating)
      {:ok, %Rating{}}

      iex> delete_rating(rating)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rating(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating) do
    allowed_roles = ["student"]
    submission = get_submission!(rating.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    cond do
      topic.allow_submission_voting == false ->
        {:error, "rating not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_delete_rating(rating)
    end
  end

  defp do_delete_rating(%Rating{} = rating) do
    Repo.delete(rating)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rating changes.

  ## Examples

      iex> change_rating(rating)
      %Ecto.Changeset{source: %Rating{}}

  """
  def change_rating(%Rating{} = rating) do
    Rating.changeset(rating, %{})
  end
end
