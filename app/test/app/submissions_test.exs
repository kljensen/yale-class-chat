defmodule App.SubmissionsTest do
  use App.DataCase

  alias App.Submissions

  describe "submissions" do
    alias App.Submissions.Submission

    @valid_attrs %{description: "some description", image_url: "some image_url", slug: "some slug", title: "some title"}
    @update_attrs %{description: "some updated description", image_url: "some updated image_url", slug: "some updated slug", title: "some updated title"}
    @invalid_attrs %{description: nil, image_url: nil, slug: nil, title: nil}

    def submission_fixture(attrs \\ %{}) do
      {:ok, submission} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Submissions.create_submission()

      submission
    end

    test "list_submissions/0 returns all submissions" do
      submission = submission_fixture()
      assert Submissions.list_submissions() == [submission]
    end

    test "get_submission!/1 returns the submission with given id" do
      submission = submission_fixture()
      assert Submissions.get_submission!(submission.id) == submission
    end

    test "create_submission/1 with valid data creates a submission" do
      assert {:ok, %Submission{} = submission} = Submissions.create_submission(@valid_attrs)
      assert submission.description == "some description"
      assert submission.image_url == "some image_url"
      assert submission.slug == "some slug"
      assert submission.title == "some title"
    end

    test "create_submission/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Submissions.create_submission(@invalid_attrs)
    end

    test "update_submission/2 with valid data updates the submission" do
      submission = submission_fixture()
      assert {:ok, %Submission{} = submission} = Submissions.update_submission(submission, @update_attrs)
      assert submission.description == "some updated description"
      assert submission.image_url == "some updated image_url"
      assert submission.slug == "some updated slug"
      assert submission.title == "some updated title"
    end

    test "update_submission/2 with invalid data returns error changeset" do
      submission = submission_fixture()
      assert {:error, %Ecto.Changeset{}} = Submissions.update_submission(submission, @invalid_attrs)
      assert submission == Submissions.get_submission!(submission.id)
    end

    test "delete_submission/1 deletes the submission" do
      submission = submission_fixture()
      assert {:ok, %Submission{}} = Submissions.delete_submission(submission)
      assert_raise Ecto.NoResultsError, fn -> Submissions.get_submission!(submission.id) end
    end

    test "change_submission/1 returns a submission changeset" do
      submission = submission_fixture()
      assert %Ecto.Changeset{} = Submissions.change_submission(submission)
    end
  end
end
