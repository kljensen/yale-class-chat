defmodule App.Submissions.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    belongs_to :submission, App.Submissions.Submission
    belongs_to :user, App.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:score, :submission_id, :user_id])
    |> validate_required([:score])
    |> foreign_key_constraint(:user_id)
    |> assoc_constraint(:user)
    |> foreign_key_constraint(:submission_id)
    |> assoc_constraint(:submission)
    |> unique_constraint(:one_rating_per_user, name: :one_rating_per_user, message: "You can only rate a submission once.")
  end
end
