defmodule App.CourseTest do
  use App.DataCase

  describe "courses" do
    alias App.Course

    @valid_attrs %{name: "Management of Software Development", department: "MGT", number: 656}
    @missing_name  %{name: nil, department: "MGT", number: 656}

    test "changeset/2 with valid data has no errors" do
      changeset = Course.changeset(%Course{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing name has errors" do
      changeset = Course.changeset(%Course{}, @missing_name)
      refute changeset.valid?
    end

  end
end
