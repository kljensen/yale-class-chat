defmodule AppWeb.Course_RoleController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.Course_Role
  alias App.Courses

  @course_admin_roles ["administrator", "owner"]

  def index(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    list = Accounts.list_course__role_users(user, course)
    user_list = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
    course_roles = Accounts.list_course_all_course_roles(user, course)
    role = App.Accounts.get_current_course__role(user, course.id, "course")
    render(conn, "index.html", course_roles: course_roles, course: course, user_list: user_list, role: role)
  end

  def bulk_new(conn, %{"course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit(user, course.id, "course") do
      true ->
        changeset = Accounts.change_course__role(%Course_Role{})
        render(conn, "bulk_new.html", course: course, changeset: changeset, role_list: @course_admin_roles)
      false -> render_error(conn, "forbidden")
      end
  end

  def bulk_create(conn, %{"course__role" => course__role_params, "course_id" => course_id}) do
    course = Courses.get_course!(course_id)
    user_auth = conn.assigns.current_user
    case App.Accounts.can_edit(user_auth, course.id, "course") do
      true ->
        user_ids = course__role_params["user_id_list"]
        course__role_params = Map.put(course__role_params, "valid_from", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(course__role_params["valid_from"]))
        course__role_params = Map.put(course__role_params, "valid_to", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(course__role_params["valid_to"]))
        case user_ids do
          "" ->
            changeset = Accounts.change_course__role(%Course_Role{})
            conn
            |> put_flash(:error, "Must submit at least one net_id")
            |> render("bulk_new.html", course: course, changeset: changeset, role_list: @course_admin_roles)

          nil ->
            changeset = Accounts.change_course__role(%Course_Role{})
            conn
            |> put_flash(:error, "Must submit at least one net_id")
            |> render("bulk_new.html", course: course, changeset: changeset, role_list: @course_admin_roles)

          _ ->
            net_id_list = String.split(user_ids, [" ", ",",";"], trim: true)
            netid1 = List.first(net_id_list)
            {:ok, user1} = App.Accounts.create_user_on_login(netid1)
            #First try to create one course role; if an error changeset is returned, show the errors
            case Accounts.create_course__role(user_auth, user1, course, course__role_params) do
              {:ok, _course__role} ->
                net_id_list = List.delete(net_id_list, netid1)
                case length(net_id_list) do
                  0 ->
                    conn
                    |> put_flash(:success, "Course  role created successfully.")
                    |> redirect(to: Routes.course_path(conn, :show, course))
                  _ ->

                    #Now that we know the course role is valid, attempt to add the role for all users
                    initial_map = %{}
                    initial_map = Map.put(initial_map, netid1, "ok")
                    result_map = Enum.reduce net_id_list, initial_map, fn net_id, acc ->
                      {:ok, user} = App.Accounts.create_user_on_login(net_id)
                      {stat, _result} = Accounts.create_course__role(user_auth, user, course, course__role_params)
                      Map.put(acc, net_id, Atom.to_string(stat))
                    end

                    result_list = Enum.map(result_map, fn {a, b} -> [a <> "=", b <> "; \n"] end)

                    case Map.values(result_map) |> Enum.member?("error") do
                      true ->
                        conn
                        |> put_flash(:error, result_list)
                        |> redirect(to: Routes.course_course__role_path(conn, :index, course))

                      false ->
                        conn
                        |> put_flash(:success, result_list)
                        |> redirect(to: Routes.course_course__role_path(conn, :index, course))
                      end
                  end

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "bulk_new.html", course: course, changeset: changeset, role_list: @course_admin_roles)

              {:error, message} -> render_error(conn, message)
              end
            end

      false -> render_error(conn, "forbidden")
      end
  end

  def show(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    course = Courses.get_course!(course__role.course_id)
    render(conn, "show.html", course__role: course__role, course: course)
  end

  def edit(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(String.to_integer(id))
    course = Courses.get_course!(course__role.course_id)
    changeset = Accounts.change_course__role(course__role)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_course__roles(user, course)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    render(conn, "edit.html", course__role: course__role, changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)
  end

  def update(conn, %{"id" => id, "course__role" => course__role_params}) do
    course__role = Accounts.get_course__role!(id)
    user = conn.assigns.current_user
    course__role_params = Map.put(course__role_params, "valid_from", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(course__role_params["valid_from"]))
    course__role_params = Map.put(course__role_params, "valid_to", AppWeb.ControllerHelpers.convert_NYC_datetime_to_db!(course__role_params["valid_to"]))

    case Accounts.update_course__role!(user, course__role, course__role_params) do
      {:ok, course__role} ->
        course = Courses.get_course!(course__role.course_id)
        conn
        |> put_flash(:success, "Course  role updated successfully.")
        |> redirect(to: Routes.course_course__role_path(conn, :show, course, course__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        course__role = Accounts.get_course__role!(String.to_integer(id))
        course = Courses.get_course!(course__role.course_id)
        list = Accounts.list_users_for_course__roles(user, course)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "edit.html", course__role: course__role, changeset: changeset, course: course, role_list: @course_admin_roles, user_list: user_list)

      {:error, message} -> render_error(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    course__role = Accounts.get_course__role!(id)
    course = Courses.get_course!(course__role.course_id)
    user = conn.assigns.current_user
    case Accounts.delete_course__role!(user, course__role) do
    {:ok, _course__role} ->
      conn
      |> put_flash(:success, "Course  role deleted successfully.")
      |> redirect(to: Routes.course_course__role_path(conn, :index, course))

    {:error, message} -> render_error(conn, message)
    end
  end
end
