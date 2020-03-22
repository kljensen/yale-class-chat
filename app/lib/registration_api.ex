defmodule RegistrationAPI do

  @moduledoc """
  Functions for interacting with the Registration API provided by Yale SOM
  """

  use Tesla

  plug Tesla.Middleware.BaseUrl, params.url
  plug Tesla.Middleware.BasicAuth, username: params.username, password: params.password
  plug Tesla.Middleware.JSON

  defp params do
    Map.new(Application.get_env(:app, RegistrationAPI))
  end

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users()
      [%User{}, ...]

  """
  def get_registered_students(crn, term_code) do

    {:ok, %Tesla.Env{:body => body}} = get("", query: ["CRN": crn, "TermCode": term_code])
    output = case body do
              "" ->
                {:error, "Invalid parameters for course registration API; please add users manually"}

              body ->
                students = body["Course"]["roster"]["student"]
                initial_list = []
                result_list = Enum.reduce students, initial_list, fn student, acc ->
                  net_id = student["netid"]
                  email = student["email"]
                  display_name = student["fullname"]
                  List.insert_at(acc, -1, %{net_id: net_id, email: email, display_name: display_name})
                end
                {:ok, result_list}
              end

    output

  end

  def get_registered_student_user_ids(crn, term_code, update_existing \\ true) do

    {:ok, %Tesla.Env{:body => body}} = get("", query: ["CRN": crn, "TermCode": term_code])
    output = case body do
                  "" ->
                    {:error, "Invalid parameters for course registration API; please add users manually"}

                  body ->
                    students = body["Course"]["roster"]["student"]
                    initial_list = []
                    result_list = Enum.reduce students, initial_list, fn student, acc ->
                      net_id = student["netid"]
                      email = student["email"]
                      display_name = student["fullname"]

                      {:ok, user} = case update_existing do
                        false -> App.Accounts.create_user_on_login(net_id)
                        true -> App.Accounts.create_or_update_user(%{net_id: net_id, email: email, display_name: display_name})
                        end

                      List.insert_at(acc, -1, %{id: user.id})
                    end
                    {:ok, result_list}
                  end

    output

  end

end
