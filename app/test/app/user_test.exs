

defmodule App.UserTest do
    use App.DataCase
    
    describe "users" do
      alias App.User
  
      @valid_attrs %{net_id: "klj34", email: "kyle.jensen@yale.edu", display_name: "Kyle Jensen"}
      @invalid_attrs  %{net_id: nil, email: "foo.jensen@yale.edu", display_name: "Foo Jensen"}
      # @update_attrs  %{net_id: "klj34", email: "foo.jensen@yale.edu", display_name: "Foo Jensen"}
  
      test "changeset/2 with valid data has no errors" do
        changeset = User.changeset(%User{}, @valid_attrs)
        assert changeset.valid?
      end

      test "changeset/2 with invalid data has errors" do
        changeset = User.changeset(%User{}, @invalid_attrs)
        refute changeset.valid?
      end
  
    end
  end