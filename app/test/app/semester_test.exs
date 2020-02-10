defmodule App.SemesterTest do
  use App.DataCase

  describe "semesters" do
    alias App.Semester

    @valid_attrs %{name: "Spring 2020"}
    @missing_name  %{name: nil}

    test "changeset/2 with valid data has no errors" do
      changeset = Semester.changeset(%Semester{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing name has errors" do
      changeset = Semester.changeset(%Semester{}, @missing_name)
      refute changeset.valid?
    end

  end
end
