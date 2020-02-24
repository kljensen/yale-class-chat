defmodule App.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :display_name, :string
    field :email, :string
    field :net_id, :string
    field :is_faculty, :boolean, default: false
    has_many :course_roles, App.Accounts.Course_Role
    has_many :section_roles, App.Accounts.Section_Role
    has_many :submissions, App.Submissions.Submission
    has_many :comments, App.Submissions.Comment
    has_many :ratings, App.Submissions.Rating

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:net_id, :display_name, :email, :is_faculty])
    |> validate_required([:net_id, :display_name, :email, :is_faculty])
    |> unique_constraint(:net_id)
    |> validate_format(:email, ~r/@/)
  end
end
