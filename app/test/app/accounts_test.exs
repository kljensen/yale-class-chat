defmodule App.AccountsTest do
  use App.DataCase

  alias App.Accounts
  alias App.CoursesTest, as: CTest

  describe "users" do
    alias App.Accounts.User

    @valid_attrs %{display_name: "some display_name", email: "some_email@yale.edu", net_id: "some net_id"}
    @update_attrs %{display_name: "some updated display_name", email: "some_updated_email@yale.edu", net_id: "some updated net_id"}
    @invalid_attrs %{display_name: nil, email: nil, net_id: nil}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert Accounts.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user unless duplicate net_id" do
      assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
      assert user.display_name == "some display_name"
      assert user.email == "some_email@yale.edu"
      assert user.net_id == "some net_id"
      assert {:error, changeset = user} = Accounts.create_user(@valid_attrs)
      assert %{net_id: ["has already been taken"]} = errors_on(changeset)
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, changeset = user} = Accounts.create_user(@invalid_attrs)
      assert %{net_id: ["can't be blank"]} = errors_on(changeset)
      assert %{display_name: ["can't be blank"]} = errors_on(changeset)
      assert %{email: ["can't be blank"]} = errors_on(changeset)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = Accounts.update_user(user, @update_attrs)
      assert user.display_name == "some updated display_name"
      assert user.email == "some_updated_email@yale.edu"
      assert user.net_id == "some updated net_id"
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, @invalid_attrs)
      assert user == Accounts.get_user!(user.id)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user(user)
    end
  end

  describe "user_roles" do
    alias App.Accounts.User_Role

    @valid_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
    @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

    def user__role_fixture(attrs \\ %{}) do
      {:ok, user__role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_user__role()

      user__role
    end

    @tag :skip
    test "list_user_roles/0 returns all user_roles" do
      user__role = user__role_fixture()
      assert Accounts.list_user_roles() == [user__role]
    end

    @tag :skip
    test "get_user__role!/1 returns the user__role with given id" do
      user__role = user__role_fixture()
      assert Accounts.get_user__role!(user__role.id) == user__role
    end

    test "create_user__role/3 with valid data creates a user__role" do
      user = user_fixture()
      section = CTest.section_fixture()

      assert {:ok, %User_Role{} = user__role} = Accounts.create_user__role(user, section, @valid_attrs)
      assert user__role.role == "some role"
      assert user__role.valid_from == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert user__role.valid_to == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    @tag :skip
    test "create_user__role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_user__role(@invalid_attrs)
    end

    @tag :skip
    test "update_user__role/2 with valid data updates the user__role" do
      user__role = user__role_fixture()
      assert {:ok, %User_Role{} = user__role} = Accounts.update_user__role(user__role, @update_attrs)
      assert user__role.role == "some updated role"
      assert user__role.valid_from == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert user__role.valid_to == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    @tag :skip
    test "update_user__role/2 with invalid data returns error changeset" do
      user__role = user__role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_user__role(user__role, @invalid_attrs)
      assert user__role == Accounts.get_user__role!(user__role.id)
    end

    @tag :skip
    test "delete_user__role/1 deletes the user__role" do
      user__role = user__role_fixture()
      assert {:ok, %User_Role{}} = Accounts.delete_user__role(user__role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_user__role!(user__role.id) end
    end

    @tag :skip
    test "change_user__role/1 returns a user__role changeset" do
      user__role = user__role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_user__role(user__role)
    end
  end

  describe "course_roles" do
    alias App.Accounts.Course_Role

    @valid_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
    @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

    def course__role_fixture(attrs \\ %{}) do
      {:ok, course__role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_course__role()

      course__role
    end

    test "list_course_roles/0 returns all course_roles" do
      course__role = course__role_fixture()
      assert Accounts.list_course_roles() == [course__role]
    end

    test "get_course__role!/1 returns the course__role with given id" do
      course__role = course__role_fixture()
      assert Accounts.get_course__role!(course__role.id) == course__role
    end

    test "create_course__role/1 with valid data creates a course__role" do
      assert {:ok, %Course_Role{} = course__role} = Accounts.create_course__role(@valid_attrs)
      assert course__role.role == "some role"
      assert course__role.valid_from == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert course__role.valid_to == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_course__role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_course__role(@invalid_attrs)
    end

    test "update_course__role/2 with valid data updates the course__role" do
      course__role = course__role_fixture()
      assert {:ok, %Course_Role{} = course__role} = Accounts.update_course__role(course__role, @update_attrs)
      assert course__role.role == "some updated role"
      assert course__role.valid_from == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert course__role.valid_to == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_course__role/2 with invalid data returns error changeset" do
      course__role = course__role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_course__role(course__role, @invalid_attrs)
      assert course__role == Accounts.get_course__role!(course__role.id)
    end

    test "delete_course__role/1 deletes the course__role" do
      course__role = course__role_fixture()
      assert {:ok, %Course_Role{}} = Accounts.delete_course__role(course__role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_course__role!(course__role.id) end
    end

    test "change_course__role/1 returns a course__role changeset" do
      course__role = course__role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_course__role(course__role)
    end
  end

  describe "section_roles" do
    alias App.Accounts.Section_Role

    @valid_attrs %{role: "some role", valid_from: "2010-04-17T14:00:00Z", valid_to: "2010-04-17T14:00:00Z"}
    @update_attrs %{role: "some updated role", valid_from: "2011-05-18T15:01:01Z", valid_to: "2011-05-18T15:01:01Z"}
    @invalid_attrs %{role: nil, valid_from: nil, valid_to: nil}

    def section__role_fixture(attrs \\ %{}) do
      {:ok, section__role} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_section__role()

      section__role
    end

    test "list_section_roles/0 returns all section_roles" do
      section__role = section__role_fixture()
      assert Accounts.list_section_roles() == [section__role]
    end

    test "get_section__role!/1 returns the section__role with given id" do
      section__role = section__role_fixture()
      assert Accounts.get_section__role!(section__role.id) == section__role
    end

    test "create_section__role/1 with valid data creates a section__role" do
      assert {:ok, %Section_Role{} = section__role} = Accounts.create_section__role(@valid_attrs)
      assert section__role.role == "some role"
      assert section__role.valid_from == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert section__role.valid_to == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_section__role/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_section__role(@invalid_attrs)
    end

    test "update_section__role/2 with valid data updates the section__role" do
      section__role = section__role_fixture()
      assert {:ok, %Section_Role{} = section__role} = Accounts.update_section__role(section__role, @update_attrs)
      assert section__role.role == "some updated role"
      assert section__role.valid_from == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert section__role.valid_to == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_section__role/2 with invalid data returns error changeset" do
      section__role = section__role_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_section__role(section__role, @invalid_attrs)
      assert section__role == Accounts.get_section__role!(section__role.id)
    end

    test "delete_section__role/1 deletes the section__role" do
      section__role = section__role_fixture()
      assert {:ok, %Section_Role{}} = Accounts.delete_section__role(section__role)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_section__role!(section__role.id) end
    end

    test "change_section__role/1 returns a section__role changeset" do
      section__role = section__role_fixture()
      assert %Ecto.Changeset{} = Accounts.change_section__role(section__role)
    end
  end
end
