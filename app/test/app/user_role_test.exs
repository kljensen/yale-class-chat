defmodule App.UserRoleTest do
  use App.DataCase

  describe "user_roles" do
    alias App.User_role

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
    @valid_attrs %{role: "student", valid_from: @valid_date}
    @missing_role %{role: nil, valid_from: @valid_date}
    @missing_valid_from %{role: "student", valid_from: nil}
    # @update_attrs  %{net_id: "klj34", email: "foo.jensen@yale.edu", display_name: "Foo Jensen"}

    test "changeset/2 with valid data has no errors" do
      changeset = User_role.changeset(%User_role{}, @valid_attrs)
      assert changeset.valid?
    end

    test "changeset/2 with missing role has errors" do
      changeset = User_role.changeset(%User_role{}, @missing_role)
      refute changeset.valid?
    end

    test "changeset/2 with missing valid_from has errors" do
      changeset = User_role.changeset(%User_role{}, @missing_valid_from)
      refute changeset.valid?
    end

  end
end
