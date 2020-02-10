defmodule App.SubmissionTest do
  use App.DataCase

  describe "submissions" do
    alias App.Submission

    @valid_attrs %{title: "Super Awesome Submission", description: "This is an incredible submission", slug: "awesome-submission-1", image_url: "https://i.imgur.com/2JZKwrO.gif"}
    @missing_title  %{title: nil, description: "This is an incredible submission", slug: "awesome-submission-1", image_url: "https://i.imgur.com/2JZKwrO.gif"}
    @missing_description %{title: "Super Awesome Submission", description: nil, slug: "awesome-submission-1", image_url: "https://i.imgur.com/2JZKwrO.gif"}
    @missing_slug %{title: "Super Awesome Submission", description: "This is an incredible submission", slug: nil, image_url: "https://i.imgur.com/2JZKwrO.gif"}

    test "changeset/2 with valid data has no errors" do
      changeset = Submission.changeset(%Submission{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing title has errors" do
      changeset = Submission.changeset(%Submission{}, @missing_title)
      refute changeset.valid?
    end

    test "changeset/2 with missing description has errors" do
      changeset = Submission.changeset(%Submission{}, @missing_description)
      refute changeset.valid?
    end

    test "changeset/2 with missing slug has errors" do
      changeset = Submission.changeset(%Submission{}, @missing_slug)
      refute changeset.valid?
    end

  end
end
