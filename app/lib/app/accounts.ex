defmodule App.Accounts do
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
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
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
              select: u_r.role

    results = Repo.all(query)
    List.first(results)
  end


  @doc """
  Creates a course__role.

  ## Examples

      iex> create_course__role(%{field: value})
      {:ok, %Course_Role{}}

      iex> create_course__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course__role(%App.Accounts.User{} = user_auth, %App.Accounts.User{} = user, %App.Courses.Course{} = course, attrs \\ %{}) do
    allowed_roles = ["owner"]
    auth_role = App.Accounts.get_current_course__role(user_auth, course)
    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
    allowed_roles = ["owner"]
    course = App.Courses.get_course!(course__role.course_id)
    auth_role = get_current_course__role(user_auth, course)
    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
    allowed_roles = ["owner"]
    course = App.Courses.get_course!(course__role.course_id)
    auth_role = get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
  Creates a section__role.

  ## Examples

      iex> create_section__role(%{field: value})
      {:ok, %Section_Role{}}

      iex> create_section__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section__role(%App.Accounts.User{} = user_auth, %App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs \\ %{}) do
    allowed_roles = ["administrator", "owner"]
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
    allowed_roles = ["administrator", "owner"]
    section = App.Courses.get_section!(section__role.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
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
    allowed_roles = ["administrator", "owner"]
    section = App.Courses.get_section!(section__role.section_id)
    course = App.Courses.get_course!(section.course_id)
    auth_role = App.Accounts.get_current_course__role(user_auth, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(allowed_roles, auth_role) == false ->
        {:error, "unauthorized"}#
      true ->
        do_delete_section__role(section__role)
    end
  end

  defp do_delete_section__role(%Section_Role{} = section__role) do
    Repo.delete(section__role)
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
