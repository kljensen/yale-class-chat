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
        |> put_flash(:info, "User created successfully.")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = unless id == "new", do: user = Accounts.get_user!(id)
        render(conn, "show.html", user: user)
      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
    end
  end

  def edit(conn, %{"id" => id}) do
    IO.inspect "Current user ID: " <> to_string(conn.assigns.current_user.id)
    IO.inspect "Passed user ID: " <> id
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        changeset = Accounts.change_user(user)
        render(conn, "edit.html", user: user, changeset: changeset)
      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        case Accounts.update_user(user, user_params) do
          {:ok, user} ->
            conn
            |> put_flash(:info, "User updated successfully.")
            |> redirect(to: Routes.user_path(conn, :show, user))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "edit.html", user: user, changeset: changeset)
        end
      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
    end
  end

  def delete(conn, %{"id" => id}) do
    case id == to_string(conn.assigns.current_user.id) do
      true ->
        user = Accounts.get_user!(id)
        {:ok, _user} = Accounts.delete_user(user)

        conn
        |> put_flash(:info, "User deleted successfully.")
        |> redirect(to: Routes.user_path(conn, :index))
      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
    end
  end
end
