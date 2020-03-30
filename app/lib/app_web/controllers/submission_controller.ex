defmodule AppWeb.SubmissionController do
  use AppWeb, :controller

  alias App.Submissions
  alias App.Submissions.Submission
  alias App.Topics
  alias App.Courses

  def index(conn, %{"topic_id" => topic_id}) do
    user = conn.assigns.current_user
    case Topics.get_user_topic(user, topic_id) do
      {:ok, topic} ->
        section = topic.section
        course = topic.section.course
        submissions = Submissions.list_user_submissions!(user, topic)
        can_edit = App.Accounts.can_edit_topic(user, topic)
        render(conn, "index.html", submissions: submissions, topic: topic, can_edit: can_edit, uid: user.id, section: section, course: course)

      {:error, message} -> render_error(conn, message)
      end
  end

  def new(conn, %{"topic_id" => topic_id}) do
    user = conn.assigns.current_user
    case Topics.get_user_topic(user, topic_id) do
      {:ok, topic} ->
        changeset = Submissions.change_submission(%Submission{})
        section = topic.section
        course = topic.section.course
        render(conn, "new.html", changeset: changeset, topic: topic, section: section, course: course)

      {:error, message} -> render_error(conn, message)
      end
  end

  def create(conn, %{"submission" => submission_params, "topic_id" => topic_id}) do
    user = conn.assigns.current_user
    case Topics.get_user_topic(user, topic_id) do
      {:ok, topic} ->
        section = topic.section
        course = topic.section.course

        case Submissions.create_submission!(user, topic, submission_params) do
          {:ok, _submission} ->
            conn
            |> put_flash(:success, "Submission created successfully.")
            |> redirect(to: Routes.topic_path(conn, :show, topic))

          {:error, %Ecto.Changeset{} = changeset} ->
            render(conn, "new.html", changeset: changeset, topic: topic, section: section, course: course)

          {:error, message} -> render_error(conn, message)
        end

      {:error, message} -> render_error(conn, message)
      end
  end

  def show(conn, %{"id" => id}) do
    user = conn.assigns.current_user
    case Submissions.get_user_submission!(user, id) do
      {:ok, submission} ->
        my_rating = Submissions.get_user_submission_rating(user.id, id)
        submission_check = Submissions.get_submission!(id)
        topic = Topics.get_topic!(submission.topic_id)
        can_edit = App.Accounts.can_edit_submission(user, submission_check)
        is_admin = App.Accounts.can_edit_topic(user, topic)
        can_edit_topic = App.Accounts.can_edit_topic(user, topic)
        comments = Submissions.list_user_comments!(user, submission_check)
        section = Courses.get_section!(topic.section_id)
        course = Courses.get_course!(section.course_id)
        comment_changeset = Submissions.change_comment(%App.Submissions.Comment{})
        rating_changeset = Submissions.change_rating(%App.Submissions.Rating{})
        render(conn, "show.html",
                submission: submission,
                topic: topic,
                can_edit: can_edit,
                uid: user.id,
                can_edit_topic: can_edit_topic,
                comments: comments,
                section: section,
                course: course,
                is_admin: is_admin,
                comment_changeset: comment_changeset,
                rating_changeset: rating_changeset,
                my_rating: my_rating)

      {:error, message} -> render_error(conn, message)
      end
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
      false -> render_error(conn, "forbidden")
      end
  end

  def update(conn, %{"id" => id, "submission" => submission_params}) do
    submission = Submissions.get_submission!(id)
    user = conn.assigns.current_user

    case Submissions.update_submission!(user, submission, submission_params) do
      {:ok, submission} ->
        conn
        |> put_flash(:success, "Submission updated successfully.")
        |> redirect(to: Routes.submission_path(conn, :show, submission))

      {:error, %Ecto.Changeset{} = changeset} ->
        topic = Topics.get_topic!(submission.topic_id)
        section = Courses.get_section!(topic.section_id)
        course = Courses.get_course!(section.course_id)
        render(conn, "edit.html", submission: submission, changeset: changeset, topic: topic, section: section, course: course)

      {:error, message} -> render_error(conn, message)
    end
  end

  def delete(conn, %{"id" => id}) do
    submission = Submissions.get_submission!(id)
    user = conn.assigns.current_user
    case App.Accounts.can_edit_submission(user, submission) do
      true ->
        topic = Topics.get_topic!(submission.topic_id)
        {:ok, _submission} = Submissions.delete_submission!(user, submission)
        conn
        |> put_flash(:success, "Submission deleted successfully.")
        |> redirect(to: Routes.topic_path(conn, :show, topic))

      false -> render_error(conn, "forbidden")
      end
  end
end
