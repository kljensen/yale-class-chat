defmodule AppWeb.SubmissionController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Submission
  alias App.Topics
  alias App.Courses

  def index(conn, %{"topic_id" => topic_id}) do
    topic = Topics.get_topic!(topic_id)
    section = Courses.get_section!(topic.section_id)
    course = Courses.get_course!(section.course_id)
    user = conn.assigns.current_user
    submissions = Submissions.list_user_submissions(user, topic)
    can_edit = App.Accounts.can_edit_topic(user, topic)
    render(conn, "index.html", submissions: submissions, topic: topic, can_edit: can_edit, uid: user.id, section: section, course: course)
  end

  def new(conn, %{"topic_id" => topic_id}) do
    changeset = Submissions.change_submission(%Submission{})
    topic = Topics.get_topic!(topic_id)
    section = Courses.get_section!(topic.section_id)
    course = Courses.get_course!(section.course_id)
    render(conn, "new.html", changeset: changeset, topic: topic, section: section, course: course)
  end

  def create(conn, %{"submission" => submission_params, "topic_id" => topic_id}) do
    user = conn.assigns.current_user
    topic = Topics.get_topic!(topic_id)
    section = Courses.get_section!(topic.section_id)
    course = Courses.get_course!(section.course_id)

    case Submissions.create_submission(user, topic, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission created successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, topic: topic, section: section, course: course)

      {:error, message} ->
        changeset = Submissions.change_submission(%Submission{})
        conn
        |> put_flash(:error, message)
        |> render("new.html", changeset: changeset, topic: topic, section: section, course: course)

    end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    submission = Submissions.get_user_submission(user, id)
    my_rating = Submissions.get_user_submission_rating(user.id, submission.id)
    submission_check = Submissions.get_submission!(submission.id)
    topic = Topics.get_topic!(submission.topic_id)
    can_edit = App.Accounts.can_edit_submission(user, submission_check)
    is_admin = App.Accounts.can_edit_topic(user, topic)
    can_edit_topic = App.Accounts.can_edit_topic(user, topic)
    comments = Submissions.list_user_comments(user, submission_check)
    section = Courses.get_section!(topic.section_id)
    course = Courses.get_course!(section.course_id)
    comment_changeset = Submissions.change_comment(%App.Submissions.Comment{})
    rating_changeset = Submissions.change_rating(%App.Submissions.Rating{})
    render(conn, "show.html", submission: submission, topic: topic, can_edit: can_edit, uid: user.id, can_edit_topic: can_edit_topic, comments: comments, section: section, course: course, is_admin: is_admin, comment_changeset: comment_changeset, rating_changeset: rating_changeset, my_rating: my_rating)
  end

  def edit(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_submission(user, submission) do
      true ->
        topic = Topics.get_topic!(submission.topic_id)
        section = Courses.get_section!(topic.section_id)
        course = Courses.get_course!(section.course_id)
        changeset = Submissions.change_submission(submission)
        render(conn, "edit.html", submission: submission, changeset: changeset, topic: topic, section: section, course: course)
      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end

  def update(conn, %{"id" => id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)
    user = conn.assigns.current_user

    case Submissions.update_submission(user, submission, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:info, "Submission updated successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        topic = Topics.get_topic!(submission.topic_id)
        section = Courses.get_section!(topic.section_id)
        course = Courses.get_course!(section.course_id)
        render(conn, "edit.html", submission: submission, changeset: changeset, topic: topic, section: section, course: course)

      {:error, message} ->
        case message do
          "forbidden" ->
            conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
          "not found" ->
            conn
            |> put_status(:not_found)
            |> put_view(AppWeb.ErrorView)
            |> render("404.html")
          end
    end
  end

  def delete(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_submission(user, submission) do
      true ->
        topic = Topics.get_topic!(submission.topic_id)
        {:ok, _submission} = Submissions.delete_submission(user, submission)
        conn
        |> put_flash(:info, "Submission deleted successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      false ->
        conn
            |> put_status(:forbidden)
            |> put_view(AppWeb.ErrorView)
            |> render("403.html")
      end
  end
end
