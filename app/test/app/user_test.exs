

defmodule App.UserTest do
    use App.DataCase

    describe "users" do
      alias App.User

      @valid_attrs %{net_id: "klj34", email: "kyle.jensen@yale.edu", display_name: "Kyle Jensen"}
      @missing_netid  %{net_id: nil, email: "foo.jensen@yale.edu", display_name: "Foo Jensen"}
      @invalid_email %{net_id: "klj34", email: "kyle.jensenyale.edu", display_name: "Kyle Jensen"}
      # @update_attrs  %{net_id: "klj34", email: "foo.jensen@yale.edu", display_name: "Foo Jensen"}

      test "changeset/2 with valid data has no errors" do
        changeset = User.changeset(%User{}, @valid_attrs)
        assert changeset.valid?
      end

      test "changeset/2 with missing net ID has errors" do
        changeset = User.changeset(%User{}, @missing_netid)
        refute changeset.valid?
      end

      test "changeset/2 with invalid email has errors" do
        changeset = User.changeset(%User{}, @invalid_email)
        refute changeset.valid?
      end

    end
  end
