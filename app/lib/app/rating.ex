defmodule App.Rating do
  use Ecto.Schema

  schema "ratings" do
    field :score, :integer
    belongs_to :submission, App.Submission
    belongs_to :user, App.User
  end

  def changeset(rating, params \\ %{}) do
    rating
    |> Ecto.Changeset.cast(params, [:score])
    |> Ecto.Changeset.validate_required([:score])
  end
end
