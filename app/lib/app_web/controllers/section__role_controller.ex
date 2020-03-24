defmodule AppWeb.Section_RoleController do
  use AppWeb, :controller
  @section_read_roles ["student", "defunct_student", "guest"]

  alias App.Accounts
  alias App.Accounts.Section_Role
  alias App.Courses

  def index(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    course = Courses.get_course!(section.course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_section(user, section) do
      true ->
        list = Accounts.list_section__role_users(user, section)
        user_list = Map.new(Enum.map(list, fn [key, value] -> {:"#{key}", value} end))
        section_roles = Accounts.list_section_all_section_roles(user, section)
        render(conn, "index.html", section_roles: section_roles, section: section, user_list: user_list, course: course)

      false -> render_error(conn, "forbidden")
      end
  end

  def new(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    course = Courses.get_course!(section.course_id)
    user = conn.assigns.current_user
    list = Accounts.list_users_for_section__roles(user, section)
    user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
    changeset = Accounts.change_section__role(%Section_Role{})
    render(conn, "new.html", changeset: changeset, section: section, role_list: @section_read_roles, user_list: user_list, course: course)
  end

  def api_new(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_section(user, section) do
      true ->
        course = Courses.get_course!(section.course_id)
        changeset = Accounts.change_section__role(%Section_Role{})
        render(conn, "api_new.html", changeset: changeset, section: section, role_list: @section_read_roles, course: course)

      false -> render_error(conn, "forbidden")
      end
  end

  def api_create(conn, %{"section__role" => section__role_params, "section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user_auth = conn.assigns.current_user
    case App.Accounts.can_edit_section(user_auth, section) do
      true ->
        course = Courses.get_course!(section.course_id)
        semester = Courses.get_semester!(course.semester_id)
        update_existing = case section__role_params["update_existing"] do
                            "true" -> true
                            _ -> false
                          end
        overwrite_roles = case section__role_params["overwrite_roles"] do
          "true" -> true
          _ -> false
        end
        case RegistrationAPI.get_registered_student_user_netids(section.crn, semester.term_code, update_existing) do
          {:ok, user_ids} ->
            case user_ids do
              "" ->
                changeset = Accounts.change_section__role(%Section_Role{})
                conn
                |> put_flash(:error, "Course Registration API returned 0 students")
                |> render("api_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

              nil ->
                changeset = Accounts.change_section__role(%Section_Role{})
                conn
                |> put_flash(:error, "Course Registration API returned 0 students")
                |> render("api_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

              _ ->
                net_id_list = user_ids
                netid1 = List.first(net_id_list)
                {:ok, user1} = App.Accounts.create_user_on_login(netid1)
                #First try to create one section role; if an error changeset is returned, show the errors
                case Accounts.create_section__role(user_auth, user1, section, section__role_params) do
                  {:ok, _section__role} ->
                    net_id_list = List.delete(net_id_list, netid1)
                    #Delete all existing section roles, then recreate the first one again
                    result = if overwrite_roles do
                                Accounts.delete_all_section__roles(user_auth, section)
                              else
                                  {0, nil}
                              end
                    case result do
                      {:error, message} ->
                        changeset = Accounts.change_section__role(%Section_Role{})
                        conn
                        |> put_flash(:error, message)
                        |> render("api_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

                      {int, _} ->
                        if int > 0 do
                          #recreate deleted section role
                          Accounts.create_section__role(user_auth, user1, section, section__role_params)
                        end
                        case length(net_id_list) do
                          0 ->
                            conn
                            |> put_flash(:success, "Section  role created successfully.")
                            |> redirect(to: Routes.section_path(conn, :show, section))
                          _ ->

                            #Now that we know the section role is valid, attempt to add the role for all users
                            initial_map = %{}
                            initial_map = Map.put(initial_map, netid1, "ok")
                            result_map = Enum.reduce net_id_list, initial_map, fn net_id, acc ->
                              {:ok, user} = App.Accounts.create_user_on_login(net_id)
                              {stat, _result} = Accounts.create_section__role(user_auth, user, section, section__role_params)
                              Map.put(acc, net_id, Atom.to_string(stat))
                            end

                            result_list = Enum.map(result_map, fn {a, b} -> [a <> "=", b <> "; \n"] end)

                            case Map.values(result_map) |> Enum.member?("error") do
                              true ->
                                conn
                                |> put_flash(:error, result_list)
                                |> redirect(to: Routes.section_section__role_path(conn, :index, section))

                              false ->
                                conn
                                |> put_flash(:success, result_list)
                                |> redirect(to: Routes.section_section__role_path(conn, :index, section))
                              end
                          end
                        end

                  {:error, %Ecto.Changeset{} = changeset} ->
                    render(conn, "api_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

                  {:error, message} -> render_error(conn, message)
                  end
                end

              {:error, message} -> render_error(conn, message)
            end

      false -> render_error(conn, "forbidden")
      end
  end

  def bulk_new(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    course = Courses.get_course!(section.course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_section(user, section) do
      true ->
        changeset = Accounts.change_section__role(%Section_Role{})
        render(conn, "bulk_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)
      false -> render_error(conn, "forbidden")
      end
  end

  def bulk_create(conn, %{"section__role" => section__role_params, "section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    course = Courses.get_course!(section.course_id)
    user_auth = conn.assigns.current_user
    case App.Accounts.can_edit_section(user_auth, section) do
      true ->
        user_ids = section__role_params["user_id_list"]
        case user_ids do
          "" ->
            changeset = Accounts.change_section__role(%Section_Role{})
            conn
            |> put_flash(:error, "Must submit at least one net_id")
            |> render("bulk_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

          nil ->
            changeset = Accounts.change_section__role(%Section_Role{})
            conn
            |> put_flash(:error, "Must submit at least one net_id")
            |> render("bulk_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

          _ ->
            net_id_list = String.split(user_ids, [" ", ",",";"], trim: true)
            netid1 = List.first(net_id_list)
            {:ok, user1} = App.Accounts.create_user_on_login(netid1)
            #First try to create one section role; if an error changeset is returned, show the errors
            case Accounts.create_section__role(user_auth, user1, section, section__role_params) do
              {:ok, _section__role} ->
                net_id_list = List.delete(net_id_list, netid1)
                case length(net_id_list) do
                  0 ->
                    conn
                    |> put_flash(:success, "Section  role created successfully.")
                    |> redirect(to: Routes.section_path(conn, :show, section))
                  _ ->

                    #Now that we know the section role is valid, attempt to add the role for all users
                    initial_map = %{}
                    initial_map = Map.put(initial_map, netid1, "ok")
                    result_map = Enum.reduce net_id_list, initial_map, fn net_id, acc ->
                      {:ok, user} = App.Accounts.create_user_on_login(net_id)
                      {stat, _result} = Accounts.create_section__role(user_auth, user, section, section__role_params)
                      Map.put(acc, net_id, Atom.to_string(stat))
                    end

                    result_list = Enum.map(result_map, fn {a, b} -> [a <> "=", b <> "; \n"] end)

                    case Map.values(result_map) |> Enum.member?("error") do
                      true ->
                        conn
                        |> put_flash(:error, result_list)
                        |> redirect(to: Routes.section_section__role_path(conn, :index, section))

                      false ->
                        conn
                        |> put_flash(:success, result_list)
                        |> redirect(to: Routes.section_section__role_path(conn, :index, section))
                      end
                  end

              {:error, %Ecto.Changeset{} = changeset} ->
                render(conn, "bulk_new.html", section: section, changeset: changeset, role_list: @section_read_roles, course: course)

              {:error, message} -> render_error(conn, message)
              end
            end

      false -> render_error(conn, "forbidden")
      end
  end

  def create(conn, %{"section__role" => section__role_params, "section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    course = Courses.get_course!(section.course_id)
    user_auth = conn.assigns.current_user
    uid = section__role_params["user_id"]
    user = Accounts.get_user!(uid)
    net_id = user.net_id
    user = Accounts.get_user_by!(net_id)
    case Accounts.create_section__role(user_auth, user, section, section__role_params) do
      {:ok, section__role} ->
        conn
        |> put_flash(:success, "Section  role created successfully.")
        |> redirect(to: Routes.section_section__role_path(conn, :show, section, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        list = Accounts.list_users_for_section__roles(user_auth, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "new.html", changeset: changeset, section: section, role_list: @section_read_roles, user_list: user_list, course: course)

      {:error, message} -> render_error(conn, message)
    end
  end

  def show(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    section = Courses.get_section!(section__role.section_id)
    course = Courses.get_course!(section.course_id)
    render(conn, "show.html", section__role: section__role, section: section, course: course)
  end

  def edit(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(String.to_integer(id))
    section = Courses.get_section!(section__role.section_id)
    course = Courses.get_course!(section.course_id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_section(user, section) do
      true ->
        changeset = Accounts.change_section__role(section__role)
        list = Accounts.list_users_for_section__roles(user, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "edit.html", section__role: section__role, changeset: changeset, section: section, role_list: @section_read_roles, user_list: user_list, course: course)

      false -> render_error(conn, "forbidden")
      end
  end

  def update(conn, %{"id" => id, "section__role" => section__role_params}) do
    section__role = Accounts.get_section__role!(id)
    user = conn.assigns.current_user

    case Accounts.update_section__role(user, section__role, section__role_params) do
      {:ok, section__role} ->
        section = Courses.get_section!(section__role.section_id)
        _course = Courses.get_course!(section.course_id)
        conn
        |> put_flash(:success, "Section  role updated successfully.")
        |> redirect(to: Routes.section_section__role_path(conn, :show, section, section__role))

      {:error, %Ecto.Changeset{} = changeset} ->
        section = Courses.get_section!(section__role.section_id)
        course = Courses.get_course!(section.course_id)
        list = Accounts.list_users_for_section__roles(user, section)
        user_list = Map.new(Enum.map(list, fn [value, key] -> {:"#{key}", value} end))
        render(conn, "edit.html", section__role: section__role, changeset: changeset, section: section, role_list: @section_read_roles, user_list: user_list, course: course)

      {:error, message} -> render_error(conn, message)
    end
  end

  def self_delete(conn, %{"section_id" => section_id}) do
    section = Courses.get_section!(section_id)
    user = conn.assigns.current_user

    #get all section roles
    roles = Accounts.list_user_section_section_roles(user, section)

    #delete each role
    for role <- roles do
      {:ok, _section__role} = Accounts.delete_section__role(user, role)
    end

    conn
    |> put_flash(:success, "Successfully left section.")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    section__role = Accounts.get_section__role!(id)
    section = Courses.get_section!(section__role.section_id)
    user = conn.assigns.current_user
    case Accounts.delete_section__role(user, section__role) do
      {:ok, _section__role} ->
        conn
        |> put_flash(:success, "Section  role deleted successfully.")
        |> redirect(to: Routes.section_section__role_path(conn, :index, section))

      {:error, message} -> render_error(conn, message)
    end
  end
end
