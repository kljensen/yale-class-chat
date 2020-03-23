defmodule App.Accounts do
  @course_owner_roles ["owner"]
  @course_admin_roles ["administrator", "owner"]
  @section_write_roles ["student"]
  @section_read_roles ["student", "defunct_student", "guest"]

  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Accounts.User
  alias App.Accounts.Course_Role
  alias App.Accounts.Section_Role

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Returns the list of users available for selection of a course role.

  ## Examples

      iex> list_users_for_course__roles()
      [%User{}, ...]

  """
  def list_users_for_course__roles(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    uid = user.id
    cid = course.id
    auth_role = get_current_course__role(user, course)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u in "users",
                order_by: u.net_id,
                select: [u.id, u.net_id]
      Repo.all(query)
    else
      []
    end
  end

  def list_users_for_section__roles(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    uid = user.id
    cid = section.course_id
    course = App.Courses.get_course!(cid)
    auth_role = get_current_course__role(user, course)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u in "users",
                select: [u.id, u.net_id]
      Repo.all(query)
    else
      []
    end
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user by net_id.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user_by!("net_id")
      %User{}

      iex> get_user_by!("invalid net_id")
      ** (Ecto.NoResultsError)

  """
  def get_user_by!(net_id), do: Repo.get_by!(User, net_id: net_id)
  def get_user_by(net_id), do: Repo.get_by(User, net_id: net_id)

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates or updates a user.

  ## Examples

      iex> create_or_update_user(%{field: value})
      {:ok, %User{}}

      iex> create_or_update_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_or_update_user(attrs \\ %{net_id: nil, display_name: nil, email: nil}) do
    net_id = attrs.net_id
    user =
      case Repo.get_by(User, net_id: net_id) do
        nil  ->
          create_user(attrs)
        user ->
          update_user(user, attrs)

      end

    #case result do
    #  {:ok, model}        -> # Inserted or updated with success
    #  {:error, changeset} -> # Something went wrong
    #end

    user
  end

  @doc """
  Creates a user upon login.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_on_login(net_id) do
    {stat, user} = case Repo.get_by(User, net_id: net_id) do
      nil ->
        # Get required fields
        display_name = net_id
        email = net_id <> "@connect.yale.edu"
        is_faculty = false
        attrs = %{display_name: display_name, email: email, net_id: net_id, is_faculty: is_faculty}
        %User{}
        |> User.changeset(attrs)
        |> Repo.insert()
      returned_user ->
        {:ok, returned_user}
      end
      {stat, user}
  end


  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    attrstmp = attrs
    attrstmp = if Map.get(attrstmp, :net_id) do
      attrstmp = Map.delete(attrstmp, :net_id)
    else
      attrstmp
    end
    attrs = attrstmp

    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{source: %User{}}

  """
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  @doc """
  Returns the list of course_roles.

  ## Examples

      iex> list_course_roles()
      [%Course_Role{}, ...]

  """
  def list_course_roles do
    Repo.all(Course_Role)
  end

  @doc """
  Returns the list of course_roles for a given user.

  ## Examples

      iex> list_user_all_course_roles(user)
      [%Course_Role{}, ...]

  """
  def list_user_all_course_roles(%App.Accounts.User{} = user) do
    uid = user.id
    query = from u_r in Course_Role,
              where: u_r.user_id == ^uid,
              select: u_r
    Repo.all(query)
  end

  @doc """
  Returns the list of course_roles for a given user in a given course.

  ## Examples

      iex> list_user_course_course_roles(user, course)
      [%Course_Role{}, ...]

  """
  def list_user_course_course_roles(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    uid = user.id
    cid = course.id
    query = from u_r in Course_Role,
              where: u_r.user_id == ^uid and u_r.course_id == ^cid,
              select: u_r
    Repo.all(query)
  end

  @doc """
  Returns the list of course_roles in a given course.

  ## Examples

      iex> list_course_all_course_roles(user, course)
      [%Course_Role{}, ...]

  """
  def list_course_all_course_roles(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    uid = user.id
    cid = course.id
    auth_role = get_current_course__role(user, course)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u_r in Course_Role,
                where: u_r.course_id == ^cid,
                select: u_r
      Repo.all(query)
    else
      []
    end
  end

  def list_course__role_users(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    uid = user.id
    cid = course.id
    auth_role = get_current_course__role(user, course)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u_r in Course_Role,
                left_join: u in "users",
                on: u_r.user_id == u.id,
                where: u_r.course_id == ^cid,
                select: [u.id, u.net_id]
      Repo.all(query)
    else
      []
    end
  end

  @doc """
  Gets a single course__role.

  Raises `Ecto.NoResultsError` if the Course  role does not exist.

  ## Examples

      iex> get_course__role!(123)
      %Course_Role{}

      iex> get_course__role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course__role!(id), do: Repo.get!(Course_Role, id)

  @doc """
  Gets the current course__role for a given user and course.

  Raises `Ecto.NoResultsError` if the Course  role does not exist.

  ## Examples

      iex> get_current_course__role(%User{}, %Course{})
      %Course_Role{}

      iex> get_current_course__role(%InvalidUser{}, %InvalidCourse{})
      ** (Ecto.NoResultsError)

  """
  def get_current_course__role(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    cid = course.id
    query = from u_r in "course_roles",
              where: u_r.user_id == ^uid and u_r.course_id == ^cid  and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  def get_current_course__role(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    cid = section.course_id
    query = from u_r in "course_roles",
              where: u_r.user_id == ^uid and u_r.course_id == ^cid  and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  def get_current_course__role(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    sid = topic.section_id
    query = from u_r in "course_roles",
              left_join: s in "sections",
              on: s.course_id == u_r.course_id,
              where: s.id == ^sid and u_r.user_id == ^uid and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  def get_current_course__role(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    tid = submission.topic_id
    query = from u_r in "course_roles",
              left_join: s in "sections",
              on: s.course_id == u_r.course_id,
              left_join: t in "topics",
              on: t.section_id == s.id,
              where: t.id == ^tid and u_r.user_id == ^uid and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  def get_current_course__role(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    suid = comment.submission_id
    query = from u_r in "course_roles",
              left_join: s in "sections",
              on: s.course_id == u_r.course_id,
              left_join: t in "topics",
              on: t.section_id == s.id,
              left_join: su in "submissions",
              on: su.topic_id == t.id,
              where: su.id == ^suid and u_r.user_id == ^uid and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  def get_current_course__role(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    suid = rating.submission_id
    query = from u_r in "course_roles",
              left_join: s in "sections",
              on: s.course_id == u_r.course_id,
              left_join: t in "topics",
              on: t.section_id == s.id,
              left_join: su in "submissions",
              on: su.topic_id == t.id,
              where: su.id == ^suid and u_r.user_id == ^uid and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
              limit: 1,
              select: u_r.role

    Repo.one(query)
  end

  @doc """
  Returns true if the current course__role is in list of edit-allowed roles for a given user and course.

  Raises `Ecto.NoResultsError` if the Course  role does not exist.

  ## Examples

      iex> can_edit_course(%User{}, %Course{})
      true

      iex> can_edit_course(%NonAuthUser{}, %Course{})
      false

  """

  def can_edit_course(%App.Accounts.User{} = user, %App.Courses.Course{} = course) do
    course_role = get_current_course__role(user, course)
    Enum.member?(@course_admin_roles, course_role)
  end

  def can_edit_section(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    course_role = get_current_course__role(user, section)
    Enum.member?(@course_admin_roles, course_role)
  end

  def can_edit_topic(%App.Accounts.User{} = user, %App.Topics.Topic{} = topic) do
    course_role = get_current_course__role(user, topic)
    Enum.member?(@course_admin_roles, course_role)
  end

  def can_edit_submission(%App.Accounts.User{} = user, %App.Submissions.Submission{} = submission) do
    course_role = get_current_course__role(user, submission)
    Enum.member?(@course_admin_roles, course_role) || user.id == submission.user_id
  end

  def can_edit_comment(%App.Accounts.User{} = user, %App.Submissions.Comment{} = comment) do
    course_role = get_current_course__role(user, comment)
    Enum.member?(@course_admin_roles, course_role) || user.id == comment.user_id
  end

  def can_edit_rating(%App.Accounts.User{} = user, %App.Submissions.Rating{} = rating) do
    course_role = get_current_course__role(user, rating)
    Enum.member?(@course_admin_roles, course_role) || user.id == rating.user_id
  end


  @doc """
  Creates a course__role.

  ## Examples

      iex> create_course__role(user_auth, user, course, %{field: value})
      {:ok, %Course_Role{}}

      iex> create_course__role(user_auth, user, course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course__role(%App.Accounts.User{} = user_auth, %App.Accounts.User{} = user, %App.Courses.Course{} = course, attrs \\ %{}) do
    auth_role = App.Accounts.get_current_course__role(user_auth, course)
    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_create_course__role(user, course, attrs)
    end
  end

  defp do_create_course__role(%App.Accounts.User{} = user, %App.Courses.Course{} = course, attrs) do
    %Course_Role{}
    |> Course_Role.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Repo.insert()
  end

  @doc """
  Updates a course__role.

  ## Examples

      iex> update_course__role(course__role, %{field: new_value})
      {:ok, %Course_Role{}}

      iex> update_course__role(course__role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_course__role(%App.Accounts.User{} = user_auth, %Course_Role{} = course__role, attrs) do
    course = App.Courses.get_course!(course__role.course_id)
    auth_role = get_current_course__role(user_auth, course)
    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_update_course__role(course__role, attrs)
    end
  end

  defp do_update_course__role(%Course_Role{} = course__role, attrs) do
    course__role
    |> Course_Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course__role.

  ## Examples

      iex> delete_course__role(course__role)
      {:ok, %Course_Role{}}

      iex> delete_course__role(course__role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course__role(%App.Accounts.User{} = user_auth, %Course_Role{} = course__role) do
    course = App.Courses.get_course!(course__role.course_id)
    auth_role = get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_delete_course__role(course__role)
    end
  end

  defp do_delete_course__role(%Course_Role{} = course__role) do
    Repo.delete(course__role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course__role changes.

  ## Examples

      iex> change_course__role(course__role)
      %Ecto.Changeset{source: %Course_Role{}}

  """
  def change_course__role(%Course_Role{} = course__role) do
    Course_Role.changeset(course__role, %{})
  end

  alias App.Accounts.Section_Role

  @doc """
  Returns the list of section_roles.

  ## Examples

      iex> list_section_roles()
      [%Section_Role{}, ...]

  """
  def list_section_roles do
    Repo.all(Section_Role)
  end

  @doc """
  Returns the list of section_roles for a given user.

  ## Examples

      iex> list_user_all_section_roles(user)
      [%Section_Role{}, ...]

  """
  def list_user_all_section_roles(%App.Accounts.User{} = user) do
    uid = user.id
    query = from u_r in Section_Role,
              where: u_r.user_id == ^uid,
              select: u_r
    Repo.all(query)
  end

  @doc """
  Returns the list of section_roles for a given user in a given section.

  ## Examples

      iex> list_user_section_section_roles(user, section)
      [%Section_Role{}, ...]

  """
  def list_user_section_section_roles(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    uid = user.id
    cid = section.id
    query = from u_r in Section_Role,
              where: u_r.user_id == ^uid and u_r.section_id == ^cid,
              select: u_r
    Repo.all(query)
  end

  @doc """
  Returns the list of section_roles in a given section.

  ## Examples

      iex> list_section_all_section_roles(user, section)
      [%Section_Role{}, ...]

  """
  def list_section_all_section_roles(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    uid = user.id
    cid = section.id
    auth_role = get_current_section__role(user, section)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u_r in Section_Role,
                where: u_r.section_id == ^cid,
                select: u_r
      Repo.all(query)
    else
      []
    end
  end

  def list_section__role_users(%App.Accounts.User{} = user, %App.Courses.Section{} = section) do
    uid = user.id
    cid = section.id
    auth_role = get_current_section__role(user, section)
    if Enum.member?(@course_admin_roles, auth_role) do
      query = from u_r in Section_Role,
                left_join: u in "users",
                on: u_r.user_id == u.id,
                where: u_r.section_id == ^cid,
                select: [u.id, u.net_id]
      Repo.all(query)
    else
      []
    end
  end

  @doc """
  Gets a single section__role.

  Raises `Ecto.NoResultsError` if the Section  role does not exist.

  ## Examples

      iex> get_section__role!(123)
      %Section_Role{}

      iex> get_section__role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_section__role!(id), do: Repo.get!(Section_Role, id)

  @doc """
  Gets the current section__role for a given user and course.

  Raises `Ecto.NoResultsError` if the Section  role does not exist.

  ## Examples

      iex> get_current_course__role(%User{}, %Section{})
      %Section_Role{}

      iex> get_current_course__role(%InvalidUser{}, %InvalidSection{})
      ** (Ecto.NoResultsError)

  """
  def get_current_section__role(%App.Accounts.User{} = user, %App.Courses.Section{} = section, inherit_course_role \\ true) do
    {:ok, current_time} = DateTime.now("Etc/UTC")
    uid = user.id
    sid = section.id
    course_role = nil
    course_role = if inherit_course_role == true do
                    cid = section.course_id
                    course = App.Courses.get_course!(cid)
                    course_role = get_current_course__role(user, course)
                  else
                    nil
                  end
    if course_role == nil do
      query = from u_r in "section_roles",
                where: u_r.user_id == ^uid and u_r.section_id == ^sid  and u_r.valid_from <= ^current_time and u_r.valid_to >= ^current_time,
                select: u_r.role

      results = Repo.all(query)
      List.first(results)
    else
        course_role
    end
  end

  @doc """
  Gets the list of students registered to the course via registration API.

  ## Examples

      iex> get_current_course__role(%User{}, %Section{})
      %Section_Role{}

      iex> get_current_course__role(%InvalidUser{}, %InvalidSection{})
      ** (Ecto.NoResultsError)

  """
  def get_registered_students(%App.Courses.Section{} = section) do
    RegistationAPI.get_registered_students(section.crn)
    "successfully called this function"
  end

  @doc """
  Creates a section__role.

  ## Examples

      iex> create_section__role(%{field: value})
      {:ok, %Section_Role{}}

      iex> create_section__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section__role(%App.Accounts.User{} = user_auth, %App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs \\ %{}) do
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_create_section__role(user, section, attrs)
    end
  end

  defp do_create_section__role(%App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs) do
    %Section_Role{}
    |> Section_Role.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:section, section)
    |> Repo.insert()
  end

  @doc """
  Updates a section__role.

  ## Examples

      iex> update_section__role(section__role, %{field: new_value})
      {:ok, %Section_Role{}}

      iex> update_section__role(section__role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_section__role(%App.Accounts.User{} = user_auth, %Section_Role{} = section__role, attrs) do
    section = App.Courses.get_section!(section__role.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_update_section__role(section__role, attrs)
    end
  end

  defp do_update_section__role(%Section_Role{} = section__role, attrs) do
    section__role
    |> Section_Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a section__role.

  ## Examples

      iex> delete_section__role(section__role)
      {:ok, %Section_Role{}}

      iex> delete_section__role(section__role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_section__role(%App.Accounts.User{} = user_auth, %Section_Role{} = section__role) do
    section = App.Courses.get_section!(section__role.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false && section__role.user_id != user_auth.id ->
        {:error, "unauthorized"}
      true ->
        do_delete_section__role(section__role)
    end
  end

  defp do_delete_section__role(%Section_Role{} = section__role) do
    Repo.delete(section__role)
  end

  @doc """
  Deletes all section__roles in section.

  ## Examples

      iex> delete_all_section__roles(user, section)
      {:ok, %Section_Role{}}

      iex> delete_section__role(section__role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_all_section__roles(%App.Accounts.User{} = user_auth, %App.Courses.Section{} = section) do
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_admin_roles, auth_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_delete_all_section__roles(section)
    end
  end

  defp do_delete_all_section__roles(%App.Courses.Section{} = section) do
    sid = section.id
    from(sr in Section_Role, where: sr.section_id == ^sid) |> Repo.delete_all
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking section__role changes.

  ## Examples

      iex> change_section__role(section__role)
      %Ecto.Changeset{source: %Section_Role{}}

  """
  def change_section__role(%Section_Role{} = section__role) do
    Section_Role.changeset(section__role, %{})
  end
end
