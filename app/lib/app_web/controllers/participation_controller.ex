defmodule AppWeb.ParticipationController do
  use AppWeb, :controller

  def course(conn, %{"course_id" => course_id}) do
    handle_download(conn, String.to_integer(course_id), "course")
  end

  def section(conn, %{"section_id" => section_id}) do
    handle_download(conn, String.to_integer(section_id), "section")
  end

  defp handle_download(conn, id, type) do
    current_user = conn.assigns.current_user

    #Generate CSV file
    filename = App.Submissions.get_participation_csv!(current_user, id, type)

    #Send file to user's browser for download
    file = File.read!(filename)
    conn
      |> put_resp_content_type("text/csv")
      |> put_resp_header(
        "content-disposition",
        "attachment; filename=\"#{filename}\"")
      |> send_resp(200, file)

    #Delete file
    App.Submissions.delete_csv(filename)
  end
end
