defmodule App.Submissions do
  @course_owner_roles ["owner"]
  @course_admin_roles ["administrator", "owner"]
  @section_write_roles ["student"]
  @section_read_roles ["student", "defunct_student", "guest"]
  @sort_list ["date - ascending", "date - descending", "rating - ascending", "rating - descending", "rating - ascending", "random"]

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
  Obeys sort.

  ## Examples

      iex> list_user_submissions!(user, topic)
      [%Submission{}, ...]

  """
  def list_user_submissions!(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, inherit_course_role \\ true) do
    tid = topic.id
    uid = user.id
    sid = topic.section_id
    allowed_section_roles = @section_read_roles

    query = from r in App.Accounts.Section_Role,
              join: s in App.Courses.Section,
              on: r.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: t in App.Topics.Topic,
              on: t.section_id == s.id,
              join: su in Submission,
              on: su.topic_id == t.id,
              left_join: ra in App.Submissions.Rating,
              on: su.id == ra.submission_id,
              left_join: co in App.Submissions.Comment,
              on: su.id == co.submission_id,
              left_join: u in App.Accounts.User,
              on: su.user_id == u.id,
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
              group_by: [su.id, u.net_id, u.display_name, u.email],
              select: %{id: su.id,
                        title: su.title,
                        description: su.description,
                        allow_ranking: su.allow_ranking,
                        visible: su.visible,
                        image_url: su.image_url,
                        inserted_at: su.inserted_at,
                        avg_rating: avg(ra.score),
                        rating_count: count(ra.id, :distinct),
                        comment_count: count(co.id, :distinct),
                        user_id: su.user_id,
                        user_netid: u.net_id,
                        user_display_name: u.display_name,
                        user_email: u.email}

    query = query
      |> order_query(topic.sort)

    query = if inherit_course_role do
      section = App.Courses.get_section!(sid)
      course = App.Courses.get_course!(section.course_id)
      auth_role = App.Accounts.get_current_course__role(user, course)
      query_tmp = if Enum.member?(@course_admin_roles, auth_role) do
        q = from su in Submission,
          left_join: ra in App.Submissions.Rating,
          on: su.id == ra.submission_id,
          left_join: co in App.Submissions.Comment,
          on: su.id == co.submission_id,
          left_join: u in App.Accounts.User,
          on: su.user_id == u.id,
          where: su.topic_id == ^tid,
          group_by: [su.id, u.net_id, u.display_name, u.email],
          select: %{id: su.id,
                        title: su.title,
                        description: su.description,
                        allow_ranking: su.allow_ranking,
                        visible: su.visible,
                        image_url: su.image_url,
                        inserted_at: su.inserted_at,
                        avg_rating: avg(ra.score),
                        rating_count: count(ra.id, :distinct),
                        comment_count: count(co.id, :distinct),
                        user_id: su.user_id,
                        user_netid: u.net_id,
                        user_display_name: u.display_name,
                        user_email: u.email}

        q = q
          |> admin_order_query(topic.sort)

        q
      else
        query
      end
      query_tmp
    else
      query
    end

    Repo.all(query)
  end

  def order_query(query, "date - descending"),
    do: order_by(query, [r, s, c, t, su, ra], desc: su.id)
  def order_query(query, "date - ascending"),
    do: order_by(query, [r, s, c, t, su, ra], asc: su.id)
  def order_query(query, "rating - descending"),
    do: order_by(query, [r, s, c, t, su, ra], desc: avg(ra.score))
  def order_query(query, "rating - ascending"),
    do: order_by(query, [r, s, c, t, su, ra], asc: avg(ra.score))
  def order_query(query, "random"),
    do: order_by(query, [r, s, c, t, su, ra], fragment("RANDOM()"))
  def order_query(query, _),
    do: order_by(query, [])

  def admin_order_query(query, "date - descending"),
    do: order_by(query, [su, ra], desc: su.id)
  def admin_order_query(query, "date - ascending"),
    do: order_by(query, [su, ra], asc: su.id)
  def admin_order_query(query, "rating - descending"),
    do: order_by(query, [su, ra], desc: avg(ra.score))
  def admin_order_query(query, "rating - ascending"),
    do: order_by(query, [su, ra], asc: avg(ra.score))
  def admin_order_query(query, "random"),
    do: order_by(query, [su, ra], fragment("RANDOM()"))
  def admin_order_query(query, _),
    do: order_by(query, [])


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
    query = from su in Submission,
              left_join: ra in App.Submissions.Rating,
              on: su.id == ra.submission_id,
              where: su.topic_id == ^tid,
              where: su.user_id == ^uid,
              group_by: su.id,
              select: %{id: su.id, title: su.title, description: su.description, allow_ranking: su.allow_ranking, visible: su.visible, image_url: su.image_url, inserted_at: su.inserted_at, avg_rating: avg(ra.score), user_id: su.user_id}
    Repo.all(query)
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
  Gets a single submission, checking for a user's auth role.

  Raises `Ecto.NoResultsError` if the Submission does not exist.

  ## Examples

      iex> get_submission!(123)
      %Submission{}

      iex> get_submission!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_submission!(%App.Accounts.User{} = user, id) do
    submission = Repo.get!(Submission, id)
    result = case App.Accounts.can_edit_submission(user, submission) do
                true ->
                  query = from su in Submission,
                            join: t in App.Topics.Topic,
                            on: su.topic_id == t.id,
                            join: s in App.Courses.Section,
                            on: t.section_id == s.id,
                            join: c in App.Courses.Course,
                            on: s.course_id == c.id,
                            left_join: ra in App.Submissions.Rating,
                            on: su.id == ra.submission_id,
                            left_join: co in App.Submissions.Comment,
                            on: su.id == co.submission_id,
                            left_join: u in App.Accounts.User,
                            on: su.user_id == u.id,
                            where: c.allow_read == true,
                            where: su.id == ^id,
                            group_by: [su.id, u.display_name],
                            select: %{id: su.id,
                                        title: su.title,
                                        description: su.description,
                                        allow_ranking: su.allow_ranking,
                                        visible: su.visible,
                                        image_url: su.image_url,
                                        inserted_at: su.inserted_at,
                                        avg_rating: avg(ra.score),
                                        rating_count: count(ra.id, :distinct),
                                        comment_count: count(co.id, :distinct),
                                        user_id: su.user_id,
                                        user_display_name: u.display_name,
                                        topic_id: su.topic_id}
                  Repo.one(query)
                false ->
                  tid = submission.topic_id
                  topic = App.Topics.get_topic!(tid)
                  uid = user.id
                  sid = topic.section_id
                  allowed_section_roles = @section_read_roles
                  query = from r in App.Accounts.Section_Role,
                            join: s in App.Courses.Section,
                            on: r.section_id == s.id,
                            join: c in App.Courses.Course,
                            on: s.course_id == c.id,
                            join: t in App.Topics.Topic,
                            on: t.section_id == s.id,
                            join: su in Submission,
                            on: su.topic_id == t.id,
                            left_join: ra in App.Submissions.Rating,
                            on: su.id == ra.submission_id,
                            left_join: co in App.Submissions.Comment,
                            on: su.id == co.submission_id,
                            left_join: u in App.Accounts.User,
                            on: su.user_id == u.id,
                            where: r.user_id == ^uid,
                            where: r.valid_from <= from_now(0, "day"),
                            where: r.valid_to >= from_now(0, "day"),
                            where: r.role in ^allowed_section_roles,
                            where: c.allow_read == true,
                            where: s.id == ^sid,
                            where: t.visible,
                            where: t.show_user_submissions,
                            where: su.visible,
                            where: su.id == ^id,
                            where: t.id == ^tid,
                            group_by: [su.id, u.display_name],
                            select: %{id: su.id,
                                        title: su.title,
                                        description: su.description,
                                        allow_ranking: su.allow_ranking,
                                        visible: su.visible,
                                        image_url: su.image_url,
                                        inserted_at: su.inserted_at,
                                        avg_rating: avg(ra.score),
                                        rating_count: count(ra.id, :distinct),
                                        comment_count: count(co.id, :distinct),
                                        user_id: su.user_id,
                                        user_display_name: u.display_name,
                                        topic_id: su.topic_id}
                    Repo.one(query)
              end
    if is_nil(result) do
      query = from s in Submission, where: s.id == ^id
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

  def get_user_submission_rating(uid, sid) do
    query = from ra in App.Submissions.Rating,
              where: ra.user_id == ^uid,
              where: ra.submission_id == ^sid
    Repo.one(query)
  end

  @doc """
  Creates a submission.

  ## Examples

      iex> create_submission!(%{field: value})
      {:ok, %Submission{}}

      iex> create_submission!(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_submission!(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, attrs \\ %{}) do
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role!(user, section)
    course_role = App.Accounts.get_current_course__role(user, course)
    {:ok, current_time} = DateTime.now("Etc/UTC")

    #Only allow admins to hide/unhide submissions or allow them to be ranked
    attrs = if Enum.member?(@course_admin_roles, course_role) do
              attrs
            else
              attrstmp = attrs

              attrstmp = if Map.get(attrstmp, :visible) do
                Map.delete(attrstmp, :visible)
              else
                attrstmp
              end

              attrstmp = if Map.get(attrstmp, :allow_ranking) do
                Map.delete(attrstmp, :allow_ranking)
              else
                attrstmp
              end

              attrstmp
            end

    cond do
      count_user_submissions(user, topic) >= [topic.user_submission_limit] && topic.user_submission_limit > 0 ->
        {:error, "user submission limit reached"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      topic.allow_submissions == false ->
        {:error, "creating submissions not allowed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@section_write_roles, auth_role) == false && Enum.member?(@course_admin_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_submission(user, topic, attrs)
    end
  end

  defp do_create_submission(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic, attrs) do
    %Submission{}
    |> Submission.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:topic, topic)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a submission.

  ## Examples

      iex> update_submission!(submission, %{field: new_value})
      {:ok, %Submission{}}

      iex> update_submission!(submission, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_submission!(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user, course)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    authorized = Enum.member?(@course_admin_roles, auth_role) or user.id == submission.user_id

    #Only allow admins to hide/unhide submissions or allow them to be ranked
    attrs = if Enum.member?(@course_admin_roles, auth_role) do
              attrs
            else
              attrstmp = attrs
              attrstmp = if Map.get(attrstmp, :visible) do
                Map.delete(attrstmp, :visible)
              else
                attrstmp
              end
              attrstmp = if Map.get(attrstmp, :allow_ranking) do
                Map.delete(attrstmp, :allow_ranking)
              else
                attrstmp
              end
              attrstmp
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

      iex> delete_submission!(submission)
      {:ok, %Submission{}}

      iex> delete_submission!(submission)
      {:error, %Ecto.Changeset{}}

  """
  def delete_submission!(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role!(user, section)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    authorized = Enum.member?(@course_admin_roles, auth_role) or user.id == submission.user_id

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

      iex> list_user_comments!(user, submission)
      [%Comment{}, ...]

  """
  def list_user_comments!(%App.Accounts.User{} = user, %Submission{} = submission, inherit_course_role \\ true) do
    tid = submission.topic_id
    topic = App.Topics.get_topic!(tid)
    uid = user.id
    suid = submission.id
    allowed_section_roles = @section_read_roles

    query = from co in Comment,
              join: su in Submission,
              on: co.submission_id == su.id,
              join: t in App.Topics.Topic,
              on: su.topic_id == t.id,
              join: s in App.Courses.Section,
              on: t.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: r in App.Accounts.Section_Role,
              on: r.section_id == s.id,
              left_join: u in App.Accounts.User,
              on: co.user_id == u.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: t.visible,
              where: t.show_user_submissions,
              where: t.show_submission_comments == true or co.user_id == ^uid,
              where: su.visible,
              where: su.id == ^suid,
              order_by: [asc: co.inserted_at],
              select: co

    query = query
            |> preload([co, su, t, s, c, r, u], [user: u])

    query = if inherit_course_role do
      auth_role = App.Accounts.get_current_course__role(user, topic)
      if Enum.member?(@course_admin_roles, auth_role) do
        querytmp = from co in Comment,
                      left_join: u in App.Accounts.User,
                      on: co.user_id == u.id,
                      where: co.submission_id == ^suid,
                      order_by: [asc: co.inserted_at]

        querytmp = querytmp
        |> preload([co, u], [user: u])

        querytmp
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
  Gets a single comment, checking for a user's auth role.

  Raises `Ecto.NoResultsError` if the Comment does not exist.

  ## Examples

      iex> get_comment!(123)
      %Comment{}

      iex> get_comment!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_comment!(%App.Accounts.User{} = user, id) do
    comment = Repo.get!(Comment, id)
    return = case App.Accounts.can_edit_comment(user, comment) do
                true ->
                  {:ok, comment}
                false ->
                  returntmp = case get_user_submission!(user, comment.submission_id) do
                                {:ok, submission} ->
                                  tid = submission.topic_id
                                  uid = user.id
                                  sid = submission.topic.section_id
                                  allowed_section_roles = @section_read_roles
                                  query = from r in App.Accounts.Section_Role,
                                            join: s in App.Courses.Section,
                                            on: r.section_id == s.id,
                                            join: c in App.Courses.Course,
                                            on: s.course_id == c.id,
                                            join: t in App.Topics.Topic,
                                            on: t.section_id == s.id,
                                            join: su in Submission,
                                            on: su.topic_id == t.id,
                                            left_join: co in App.Submissions.Comment,
                                            on: su.id == co.submission_id,
                                            where: r.user_id == ^uid,
                                            where: r.valid_from <= from_now(0, "day"),
                                            where: r.valid_to >= from_now(0, "day"),
                                            where: r.role in ^allowed_section_roles,
                                            where: c.allow_read == true,
                                            where: s.id == ^sid,
                                            where: t.visible,
                                            where: t.show_user_submissions,
                                            where: su.visible,
                                            where: su.id == ^id,
                                            where: t.id == ^tid,
                                            where: co.id == ^id,
                                            select: co
                                  Repo.one(query)

                                {:error, message} ->
                                  {:error, message}
                                end
              end
    return
  end


  @doc """
  Creates a comment.

  ## Examples

      iex> create_comment!(%{field: value})
      {:ok, %Comment{}}

      iex> create_comment!(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_comment!(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role!(user, section)
    course_role = App.Accounts.get_current_course__role(user, section)
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
      Enum.member?(@section_write_roles, auth_role)  == false && Enum.member?(@course_admin_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_comment(user, submission, attrs)
    end
  end

  defp do_create_comment(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs) do
    %Comment{}
    |> Comment.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:submission, submission)
    |> Repo.insert()
  end

  @doc """
  Updates a comment.

  ## Examples

      iex> update_comment!(comment, %{field: new_value})
      {:ok, %Comment{}}

      iex> update_comment!(comment, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_comment!(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment, attrs \\ %{}) do
    submission = get_submission!(comment.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    course_role = App.Accounts.get_current_course__role(user, section)

    cond do
      topic.allow_submission_comments == false ->
        {:error, "commenting not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      user.id != comment.user_id && Enum.member?(@course_admin_roles, course_role) == false ->
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

      iex> delete_comment!(comment)
      {:ok, %Comment{}}

      iex> delete_comment!(comment)
      {:error, %Ecto.Changeset{}}

  """
  def delete_comment!(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment) do
    submission = get_submission!(comment.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      topic.allow_submission_comments == false ->
        {:error, "commenting not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
        user.id != comment.user_id && Enum.member?(@course_admin_roles, course_role) == false ->
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
  Returns the list of ratings for a given submission.

  ## Examples

      iex> list_ratings(submission)
      [%Rating{}, ...]

  """
  def list_ratings(%Submission{} = submission) do
    suid = submission.id
    Repo.all(from ra in Rating, where: ra.submission_id == ^suid)
  end

  @doc """
  Returns the list of ratings visible to a given user for a given submission.

  ## Examples

      iex> list_user_ratings!(user, submission)
      [%Rating{}, ...]

  """
  def list_user_ratings!(%App.Accounts.User{} = user, %Submission{} = submission, inherit_course_role \\ true) do
    tid = submission.topic_id
    topic = App.Topics.get_topic!(tid)
    uid = user.id
    sid = topic.section_id
    suid = submission.id
    allowed_section_roles = @section_read_roles

    query = from r in App.Accounts.Section_Role,
              join: s in App.Courses.Section,
              on: r.section_id == s.id,
              join: c in App.Courses.Course,
              on: s.course_id == c.id,
              join: t in App.Topics.Topic,
              on: t.section_id == s.id,
              join: su in Submission,
              on: su.topic_id == t.id,
              join: ra in Rating,
              on: ra.submission_id == su.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: t.visible,
              where: t.show_user_submissions,
              where: t.show_submission_ratings == true or ra.user_id == ^uid,
              where: su.visible,
              where: su.id == ^suid,
              select: ra

    query = if inherit_course_role do
      section = App.Courses.get_section!(sid)
      course = App.Courses.get_course!(section.course_id)
      auth_role = App.Accounts.get_current_course__role(user, course)
      if Enum.member?(@course_admin_roles, auth_role) do
        from ra in Rating,
          where: ra.submission_id == ^suid
      else
        query
      end
    else
      query
    end

    Repo.all(query)
  end

  @doc """
  Returns the list of ratings by a given user.

  ## Examples

      iex> list_user_own_ratings(user)
      [%Rating{}, ...]

  """
  def list_user_own_ratings(%App.Accounts.User{} = user) do
    uid = user.id
    Repo.all(from ra in Rating, where: ra.user_id == ^uid)
  end

  @doc """
  Returns the list of ratings by a given user for a given submission.

  ## Examples

      iex> list_user_own_ratings(user, submission)
      [%Rating{}, ...]

  """
  def list_user_own_ratings(%App.Accounts.User{} = user, %Submission{} = submission) do
    suid = submission.id
    uid = user.id
    Repo.all(from ra in Rating, where: ra.submission_id == ^suid, where: ra.user_id == ^uid)
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
  Gets a single rating, checking for a user's auth role.

  Raises `Ecto.NoResultsError` if the Rating does not exist.

  ## Examples

      iex> get_rating!(123)
      %Rating{}

      iex> get_rating!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_rating!(%App.Accounts.User{} = user, id) do
    rating = Repo.get!(Rating, id)
    return = case App.Accounts.can_edit_rating(user, rating) do
                true ->
                  rating
                false ->
                  submission = get_submission!(rating.submission_id)
                  tid = submission.topic_id
                  topic = App.Topics.get_topic!(tid)
                  uid = user.id
                  sid = topic.section_id
                  allowed_section_roles = @section_read_roles
                  query = from r in App.Accounts.Section_Role,
                            join: s in App.Courses.Section,
                            on: r.section_id == s.id,
                            join: c in App.Courses.Course,
                            on: s.course_id == c.id,
                            join: t in App.Topics.Topic,
                            on: t.section_id == s.id,
                            join: su in Submission,
                            on: su.topic_id == t.id,
                            left_join: ra in App.Submissions.Rating,
                            on: su.id == ra.submission_id,
                            where: r.user_id == ^uid,
                            where: r.valid_from <= from_now(0, "day"),
                            where: r.valid_to >= from_now(0, "day"),
                            where: r.role in ^allowed_section_roles,
                            where: c.allow_read == true,
                            where: s.id == ^sid,
                            where: t.visible,
                            where: t.show_user_submissions,
                            where: su.visible,
                            where: su.id == ^id,
                            where: t.id == ^tid,
                            where: ra.id == ^id,
                            select: ra
                  Repo.one(query)
              end
    return
  end

  @doc """
  Creates a rating.

  ## Examples

      iex> create_rating!(%{field: value})
      {:ok, %Rating{}}

      iex> create_rating!(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rating!(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission, attrs \\ %{}) do
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_section__role!(user, section)
    course_role = App.Accounts.get_current_course__role(user, section)
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
        Enum.member?(@section_write_roles, auth_role)  == false && Enum.member?(@course_admin_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_rating(user, submission, attrs)
    end
  end

  defp do_create_rating(user, submission, attrs) do
    %Rating{}
    |> Rating.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:submission, submission)
    |> Repo.insert()
  end

  @doc """
  Updates a rating.

  ## Examples

      iex> update_rating!(rating, %{field: new_value})
      {:ok, %Rating{}}

      iex> update_rating!(rating, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rating!(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating, attrs \\ %{}) do
    submission = get_submission!(rating.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      topic.allow_submission_voting == false ->
        {:error, "rating not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
      user.id != rating.user_id && Enum.member?(@course_admin_roles, course_role) == false ->
        {:error, "unauthorized"}
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

      iex> delete_rating!(rating)
      {:ok, %Rating{}}

      iex> delete_rating!(rating)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rating!(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating) do
    submission = get_submission!(rating.submission_id)
    topic = App.Topics.get_topic!(submission.topic_id)
    section = App.Courses.get_section!(topic.section_id)
    course = App.Courses.get_course!(section.course_id)
    {:ok, current_time} = DateTime.now("Etc/UTC")
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      topic.allow_submission_voting == false ->
        {:error, "rating not allowed"}
      Date.compare(current_time, topic.opened_at) == :lt ->
        {:error, "topic not yet open"}
      Date.compare(current_time, topic.closed_at) == :gt ->
        {:error, "topic closed"}
      course.allow_write == false ->
        {:error, "course write not allowed"}
        user.id != rating.user_id && Enum.member?(@course_admin_roles, course_role) == false ->
        {:error, "unauthorized"}
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
