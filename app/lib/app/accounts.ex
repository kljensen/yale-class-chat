defmodule App.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false
  alias App.Repo

  alias App.Accounts.User

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

  alias App.Accounts.User_Role

  @doc """
  Returns the list of user_roles.

  ## Examples

      iex> list_user_roles()
      [%User_Role{}, ...]

  """
  def list_user_roles do
    Repo.all(User_Role)
  end

  @doc """
  Gets a single user__role.

  Raises `Ecto.NoResultsError` if the User  role does not exist.

  ## Examples

      iex> get_user__role!(123)
      %User_Role{}

      iex> get_user__role!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user__role!(id), do: Repo.get!(User_Role, id)

  @doc """
  Creates a user__role.

  ## Examples

      iex> create_user__role(%{field: value})
      {:ok, %User_Role{}}

      iex> create_user__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user__role(%App.Accounts.User{} = user, %App.Courses.Section{} = section, attrs \\ %{}) do
    %User_Role{}
    |> User_Role.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Ecto.Changeset.put_assoc(:section, section)
    |> Repo.insert()
  end

  @doc """
  Updates a user__role.

  ## Examples

      iex> update_user__role(user__role, %{field: new_value})
      {:ok, %User_Role{}}

      iex> update_user__role(user__role, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user__role(%User_Role{} = user__role, attrs) do
    user__role
    |> User_Role.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user__role.

  ## Examples

      iex> delete_user__role(user__role)
      {:ok, %User_Role{}}

      iex> delete_user__role(user__role)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user__role(%User_Role{} = user__role) do
    Repo.delete(user__role)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user__role changes.

  ## Examples

      iex> change_user__role(user__role)
      %Ecto.Changeset{source: %User_Role{}}

  """
  def change_user__role(%User_Role{} = user__role) do
    User_Role.changeset(user__role, %{})
  end

  alias App.Accounts.Course_Role

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
  Creates a course__role.

  ## Examples

      iex> create_course__role(%{field: value})
      {:ok, %Course_Role{}}

      iex> create_course__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_course__role(attrs \\ %{}) do
    %Course_Role{}
    |> Course_Role.changeset(attrs)
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
  def update_course__role(%Course_Role{} = course__role, attrs) do
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
  def delete_course__role(%Course_Role{} = course__role) do
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
  Creates a section__role.

  ## Examples

      iex> create_section__role(%{field: value})
      {:ok, %Section_Role{}}

      iex> create_section__role(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_section__role(attrs \\ %{}) do
    %Section_Role{}
    |> Section_Role.changeset(attrs)
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
  def update_section__role(%Section_Role{} = section__role, attrs) do
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
  def delete_section__role(%Section_Role{} = section__role) do
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
