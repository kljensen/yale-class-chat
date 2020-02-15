defmodule App.Rating do
  use Ecto.Schema
  import Ecto.Changeset

  schema "ratings" do
    field :score, :integer
    belongs_to :submission, App.Submission
    belongs_to :user, App.User

    timestamps()
  end

  @doc false
  def changeset(rating, attrs) do
    rating
    |> cast(attrs, [:score])
    |> validate_required([:score])
  end
end
