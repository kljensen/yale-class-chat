defmodule AppWeb.UserController do
  use AppWeb, :controller

  alias App.Accounts
  alias App.Accounts.User

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = unless id == "new", do: Accounts.get_user!(id)
        render(conn, "show.html", user: user)
      false -> render_error(conn, "forbidden")
    end
  end

  def edit(conn, %{"id" => id}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        changeset = Accounts.change_user(user)
        render(conn, "edit.html", user: user, changeset: changeset)
      false -> render_error(conn, "forbidden")
      end
  end

  def refresh(conn, _params) do
    case Accounts.update_user_ldap(conn.assigns.current_user.net_id) do
      {:ok, user} ->
        conn
        |> put_flash(:success, "Successfully refreshed user data")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, message} -> render_error(conn, message)
      end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        case Accounts.update_user(user, user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:success, "User updated successfully.")
            |> redirect(to: Routes.user_path(conn, :show, user))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
      false -> render_error(conn, "forbidden")
    end
  end

  def delete(conn, %{"id" => id}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        {:ok, _user} = Accounts.delete_user(user)

        conn
        |> put_flash(:success, "User deleted successfully.")
        |> redirect(to: "/")
      false -> render_error(conn, "forbidden")
    end
  end
end
