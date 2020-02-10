defmodule App.SectionTest do
  use App.DataCase

  describe "sections" do
    alias App.Section

    @valid_attrs %{title: "01", crn: "29200"}
    @missing_title  %{title: nil, crn: "29200"}

    test "changeset/2 with valid data has no errors" do
      changeset = Section.changeset(%Section{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing title has errors" do
      changeset = Section.changeset(%Section{}, @missing_title)
      refute changeset.valid?
    end

  end
end
