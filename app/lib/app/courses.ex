defmodule App.Courses do
  @course_owner_roles ["owner"]
  @course_admin_roles ["administrator", "owner"]
  @section_write_roles ["student"]
  @section_read_roles ["student", "defunct_student", "guest"]

  @moduledoc """
  The Courses context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Courses.Semester

  @doc """
  Returns the list of semesters.

  ## Examples

      iex> list_semesters()
      [%Semester{}, ...]

  """
  def list_semesters do
    Repo.all(Semester)
  end

  @doc """
  Gets a single semester.

  Raises `Ecto.NoResultsError` if the Semester does not exist.

  ## Examples

      iex> get_semester!(123)
      %Semester{}

      iex> get_semester!(456)
      ** (Ecto.NoResultsError)

  """
  def get_semester!(id), do: Repo.get!(Semester, id)

  @doc """
  Gets a single semester by name.

  Raises `Ecto.NoResultsError` if the Semester does not exist.

  ## Examples

      iex> get_semester_by!(Fall 2019)
      %Semester{}

      iex> get_semester!(Never 9999)
      ** (Ecto.NoResultsError)

  """
  def get_semester_by!(name), do: Repo.get_by!(Semester, name: name)

  def list_semester_names do
    query = from s in Semester,
              select: [s.id, s.name]
    Repo.all(query)
  end

  @doc """
  Creates a semester.

  ## Examples

      iex> create_semester(%{field: value})
      {:ok, %Semester{}}

      iex> create_semester(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_semester(%App.Accounts.User{} = user, attrs \\ %{}) do
    if user.is_faculty == true do
      do_create_semester(attrs)
    else
      {:error, "unauthorized"}
    end
  end

  defp do_create_semester(attrs) do
    %Semester{}
    |> Semester.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a semester.

  ## Examples

      iex> update_semester(semester, %{field: new_value})
      {:ok, %Semester{}}

      iex> update_semester(semester, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_semester(%App.Accounts.User{} = user, %Semester{} = semester, attrs \\ %{}) do
    if user.is_faculty == true do
      do_update_semester(semester, attrs)
    else
      {:error, "unauthorized"}
    end
  end

  defp do_update_semester(%Semester{} = semester, attrs) do
    semester
    |> Semester.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a semester.

  ## Examples

      iex> delete_semester(semester)
      {:ok, %Semester{}}

      iex> delete_semester(semester)
      {:error, %Ecto.Changeset{}}

  """
  def delete_semester(%App.Accounts.User{} = user, %Semester{} = semester) do
    if user.is_faculty == true do
      do_delete_semester(semester)
    else
      {:error, "unauthorized"}
    end
  end

  defp do_delete_semester(%Semester{} = semester) do
    Repo.delete(semester)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking semester changes.

  ## Examples

      iex> change_semester(semester)
      %Ecto.Changeset{source: %Semester{}}

  """
  def change_semester(%Semester{} = semester) do
    Semester.changeset(semester, %{})
  end

  alias App.Courses.Course

  @doc """
  Returns the list of courses.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_courses do
    Repo.all(Course)
  end

  @doc """
  Returns the list of courses for which a user has a valid course_role.

  ## Examples

      iex> list_user_courses(user)
      [%Course{}, ...]

  """
  def list_user_courses(%App.Accounts.User{} = user) do
    uid = user.id
    query = from r in App.Accounts.Course_Role,
              left_join: c in Course,
              on: r.course_id == c.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              select: c
    Repo.all(query)
  end

  @doc """
  Returns the list of courses in the given semester.

  ## Examples

      iex> list_courses(semester)
      [%Course{}, ...]

  """
  def list_courses(%App.Courses.Semester{} = semester) do
    sid = semester.id
    query = from c in Course,
              where: c.semester_id == ^sid,
              select: c
    Repo.all(query)
  end

  @doc """
  Returns the list of courses for which a user has a valid course_role in a given semester.

  ## Examples

      iex> list_user_courses(semester, user)
      [%Course{}, ...]

  """
  def list_user_courses(%App.Courses.Semester{} = semester, %App.Accounts.User{} = user) do
    uid = user.id
    sid = semester.id
    query = from r in App.Accounts.Course_Role,
              left_join: c in Course,
              on: r.course_id == c.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: c.semester_id == ^sid,
              select: c
    Repo.all(query)
  end

  @doc """
  Gets a single course.

  Raises `Ecto.NoResultsError` if the Course does not exist.

  ## Examples

      iex> get_course!(123)
      %Course{}

      iex> get_course!(456)
      ** (Ecto.NoResultsError)

  """
  def get_course!(id), do: Repo.get!(Course, id)

  @doc """
  Gets a single course if user is able to view.

  ## Examples

      iex> get_user_course(user, 123)
      {:ok, %Course{}}

      iex> get_user_course(invaliduser, 123)
      {:error, message}

  """
  def get_user_course(%App.Accounts.User{} = user, course_id) do
    uid = user.id
    query = from r in App.Accounts.Course_Role,
              left_join: c in Course,
              on: r.course_id == c.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: c.id == ^course_id,
              select: c
    result = Repo.one(query)

    if is_nil(result) do
      query = from c in Course, where: c.id == ^course_id
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
  Gets a single course if user is able to view.

  ## Examples

      iex> get_user_course(user, 123)
      {:ok, %Course{}}

      iex> get_user_course(invaliduser, 123)
      {:error, message}

  """
  def get_user_course(%App.Accounts.User{} = user, course_id) do
    uid = user.id
    query = from r in App.Accounts.Course_Role,
              left_join: c in Course,
              on: r.course_id == c.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: c.id == ^course_id,
              select: c
    result = Repo.one(query)

    if is_nil(result) do
      query = from c in Course, where: c.id == ^course_id
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
  Creates a course.

  ## Examples

      iex> create_course(%{User}, %{field: value})
      {:ok, %Course{}}

      iex> create_course(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def create_course(%App.Accounts.User{} = user, %App.Courses.Semester{} = semester, attrs \\ %{}) do
    if user.is_faculty == true do
      {stat, course} = do_create_course(semester, attrs)

      if stat == :ok do
        #Add user to course as owner
        {:ok, current_time} = DateTime.now("Etc/UTC")
        attrs = %{role: "owner", valid_from: current_time, valid_to: "2100-01-01T00:00:00Z"}
        %App.Accounts.Course_Role{}
        |> App.Accounts.Course_Role.changeset(attrs)
        |> Ecto.Changeset.put_assoc(:user, user)
        |> Ecto.Changeset.put_assoc(:course, course)
        |> Repo.insert()
      end

      {stat, course}
    else
      {:error, "unauthorized"}
    end
  end

  defp do_create_course(%App.Courses.Semester{} = semester, attrs) do
    %Course{}
    |> Course.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:semester, semester)
    |> Repo.insert()
  end

  @doc """
  Updates a course.

  ## Examples

      iex> update_course(course, %{field: new_value})
      {:ok, %Course{}}

      iex> update_course(course, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  def update_course(%App.Accounts.User{} = user, %Course{} = course, attrs) do
    course_role = App.Accounts.get_current_course__role(user, course)

    if Enum.member?(@course_owner_roles, course_role) do
      do_update_course(course, attrs)
    else
      {:error, "unauthorized"}
    end
  end

  defp do_update_course(%Course{} = course, attrs) do
    course
    |> Course.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a course.

  ## Examples

      iex> delete_course(course)
      {:ok, %Course{%App%App.Courses.Semester{} = semester, attrs \\ %{}) do.Courses.Semester{} = semester, attrs \\ %{}) do}}

      iex> delete_course(course)
      {:error, %Ecto.Changeset{}}

  """
  def delete_course(%App.Accounts.User{} = user, %Course{} = course) do
    course_role = App.Accounts.get_current_course__role(user, course)

    if Enum.member?(@course_owner_roles, course_role) do
      do_delete_course(course)
    else
      {:error, "unauthorized"}
    end
  end

  defp do_delete_course(%Course{} = course) do
    Repo.delete(course)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking course changes.

  ## Examples

      iex> change_course(course)
      %Ecto.Changeset{source: %Course{}}

  """
  def change_course(%Course{} = course) do
    Course.changeset(course, %{})
  end

  alias App.Courses.Section

  @doc """
  Returns the list of sections.

  ## Examples

      iex> list_sections()
      [%Section{}, ...]

  """
  def list_sections do
    Repo.all(Section)
  end

  @doc """
  Returns the list of sections for which a user had a valid section role.

  ## Examples

      iex> list_courses()
      [%Course{}, ...]

  """
  def list_user_sections(%App.Accounts.User{} = user) do
    uid = user.id
    query = from r in App.Accounts.Section_Role,
              left_join: s in Section,
              on: r.section_id == s.id,
              left_join: c in Course,
              on: s.course_id == c.id,
              left_join: se in Semester,
              on: c.semester_id == se.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: c.allow_read == true,
              select: %{id: s.id, title: s.title, crn: s.crn, course_num: c.number, course_dept: c.department, course_name: c.name, semester_name: se.name}
    Repo.all(query)
  end

  @doc """
  Returns the list of sections for a given course.

  ## Examples

      iex> list_sections(course)
      [%Section{}, ...]

  """
  def list_sections(%Course{} = course) do
    cid = course.id
    query = from s in Section,
              where: s.course_id == ^cid,
              select: s
    Repo.all(query)
  end

  @doc """
  Returns the list of sections for which a user had a valid section role for a given course.

  ## Examples

      iex> list_user_sections(course, user)
      [%Course{}, ...]

  """
  def list_user_sections(%Course{} = course, %App.Accounts.User{} = user, inherit_course_role \\ true) do
    allowed_course_roles = @course_admin_roles
    auth_role = App.Accounts.get_current_course__role(user, course)
    uid = user.id
    cid = course.id
    allowed_section_roles = @section_read_roles
    query = from r in App.Accounts.Section_Role,
              left_join: s in Section,
              on: r.section_id == s.id,
              left_join: c in Course,
              on: s.course_id == c.id,
              where: r.user_id == ^uid,
              where: r.valid_from <= from_now(0, "day"),
              where: r.valid_to >= from_now(0, "day"),
              where: r.role in ^allowed_section_roles,
              where: c.allow_read == true,
              where: s.course_id == ^cid,
              select: s
    query = if inherit_course_role and Enum.member?(allowed_course_roles, auth_role) do
      from s in Section,
        where: s.course_id == ^cid,
        select: s
    else
        query
    end
    Repo.all(query)
  end

  @doc """
  Gets a single section.

  Raises `Ecto.NoResultsError` if the Section does not exist.

  ## Examples

      iex> get_section!(123)
      %Section{}

      iex> get_section!(456)
      ** (Ecto.NoResultsError)

  """
  def get_section!(id), do: Repo.get!(Section, id)

  @doc """
  Gets a single section if user is able to view.

  ## Examples

      iex> get_user_section(user, 123)
      {:ok, %Section{}}

      iex> get_user_section(invaliduser, 123)
      {:error, message}

  """
  def get_user_section(%App.Accounts.User{} = user, section_id, inherit_course_role \\ true) do
    allowed_course_roles = @course_admin_roles
    section = Repo.get(Section, section_id)
    query = if !is_nil(section) do
      course = Repo.get(Course, section.course_id)
      auth_role = App.Accounts.get_current_course__role(user, course)
      uid = user.id
      cid = course.id
      allowed_section_roles = @section_read_roles
      query = from r in App.Accounts.Section_Role,
                left_join: s in Section,
                on: r.section_id == s.id,
                left_join: c in Course,
                on: s.course_id == c.id,
                where: r.user_id == ^uid,
                where: r.valid_from <= from_now(0, "day"),
                where: r.valid_to >= from_now(0, "day"),
                where: r.role in ^allowed_section_roles,
                where: c.allow_read == true,
                where: s.course_id == ^cid,
                where: s.id == ^section_id,
                select: s
      query = if inherit_course_role and Enum.member?(allowed_course_roles, auth_role) do
        from s in Section,
          where: s.id == ^section_id,
          select: s
      else
          query
      end
    else
      nil
    end
    result = if !is_nil(query), do: Repo.one(query)

    if is_nil(result) do
      query = from s in Section, where: s.id == ^section_id
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
  Creates a section.

  ## Examples

      iex> create_section(%{field: value})
      {:ok, %Section{}}

      iex> create_section(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section(%App.Accounts.User{} = user, %App.Courses.Course{} = course, attrs \\ %{}) do
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_create_section(course, attrs)
    end
  end

  defp do_create_section(%App.Courses.Course{} = course, attrs \\ %{}) do
    %Section{}
    |> Section.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:course, course)
    |> Repo.insert()
  end

  @doc """
  Updates a section.

  ## Examples

      iex> update_section(section, %{field: new_value})
      {:ok, %Section{}}

      iex> update_section(section, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_section(%App.Accounts.User{} = user, %Section{} = section, attrs) do
    #If user role is Administrator or Owner, then allow update of a section
    course = get_course!(section.course_id)
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_update_section(section, attrs)
    end
  end

  defp do_update_section(%Section{} = section, attrs) do
    section
    |> Section.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a section.

  ## Examples

      iex> delete_section(section)
      {:ok, %Section{}}

      iex> delete_section(section)
      {:error, %Ecto.Changeset{}}

  """
  def delete_section(%App.Accounts.User{} = user, %Section{} = section) do
    course = get_course!(section.course_id)
    course_role = App.Accounts.get_current_course__role(user, course)

    cond do
      course.allow_write == false ->
        {:error, "course write not allowed"}
      Enum.member?(@course_owner_roles, course_role) == false ->
        {:error, "unauthorized"}
      true ->
        do_delete_section(section)
    end
  end

  defp do_delete_section(%Section{} = section) do
    Repo.delete(section)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking section changes.

  ## Examples

      iex> change_section(section)
      %Ecto.Changeset{source: %Section{}}

  """
  def change_section(%Section{} = section) do
    Section.changeset(section, %{})
  end
end
