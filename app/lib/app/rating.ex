defmodule App.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    belongs_to :submission, App.Submission
    belongs_to :user, App.User

    timestemps()
  end

  @doc false
  def changeset(rating, params \\ %{}) do
    rating
    |> cast(params, [:score])
    |> validate_required([:score])
  end
end
