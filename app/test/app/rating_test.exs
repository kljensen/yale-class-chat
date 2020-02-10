defmodule App.RatingTest do
  use App.DataCase

  describe "ratings" do
    alias App.Rating

    @valid_attrs %{score: 1}
    @missing_score  %{score: nil}

    test "changeset/2 with valid data has no errors" do
      changeset = Rating.changeset(%Rating{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing score has errors" do
      changeset = Rating.changeset(%Rating{}, @missing_score)
      refute changeset.valid?
    end

  end
end
