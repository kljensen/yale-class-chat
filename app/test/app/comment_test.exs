defmodule App.CommentTest do
  use App.DataCase

  describe "comments" do
    alias App.Comment

    @valid_attrs %{title: "My super great comment", description: "This is an example of an awesome comment"}
    @missing_title  %{title: nil, description: "This is an example of an awesome comment"}

    test "changeset/2 with valid data has no errors" do
      changeset = Comment.changeset(%Comment{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing title has errors" do
      changeset = Comment.changeset(%Comment{}, @missing_title)
      refute changeset.valid?
    end

  end
end
