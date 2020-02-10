defmodule App.TopicTest do
  use App.DataCase

  describe "topics" do
    alias App.Topic

    @valid_date %DateTime{
      calendar: Calendar.ISO,
      year: 2000,
      month: 1,
      day: 1,
      hour: 12,
      minute: 34,
      second: 56,
      std_offset: 0,
      utc_offset: 0,
      time_zone: "Etc/UTC",
      zone_abbr: "UTC"
    }
    @valid_attrs %{title: "Super Awesome Topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_title  %{title: nil, description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_slug %{title: "Super Awesome topic", description: "This is an incredible topic", slug: nil, opened_at: @valid_date, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_opened_at %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: nil, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_allow_submissions %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: nil, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_allow_submission_voting %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: nil, allow_submission_voting: nil, anonymous: true, allow_submission_comments: true, sort: "random"}
    @missing_anonymous %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: nil, allow_submission_comments: true, sort: "random"}
    @missing_allow_submission_comments %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: nil, sort: "random"}
    @missing_sort %{title: "Super Awesome topic", description: "This is an incredible topic", slug: "awesome-topic-1", opened_at: @valid_date, closed_at: @valid_date, allow_submissions: true, allow_submission_voting: true, anonymous: true, allow_submission_comments: true, sort: nil}

    test "changeset/2 with valid data has no errors" do
      changeset = Topic.changeset(%Topic{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing title has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_title)
      refute changeset.valid?
    end

    test "changeset/2 with missing slug has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_slug)
      refute changeset.valid?
    end

    test "changeset/2 with missing opened_at has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_opened_at)
      refute changeset.valid?
    end

    test "changeset/2 with missing allow_submissions has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_allow_submissions)
      refute changeset.valid?
    end

    test "changeset/2 with missing allow_submission_voting has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_allow_submission_voting)
      refute changeset.valid?
    end

    test "changeset/2 with missing anonymous has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_anonymous)
      refute changeset.valid?
    end

    test "changeset/2 with missing allow_submission_comments has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_allow_submission_comments)
      refute changeset.valid?
    end

    test "changeset/2 with missing sort has errors" do
      changeset = Topic.changeset(%Topic{}, @missing_sort)
      refute changeset.valid?
    end


  end
end
