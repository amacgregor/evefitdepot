defmodule Evefitdepot.Fittings.Fitting do
  use Ecto.Schema
  import Ecto.Changeset

  schema "fittings" do


    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(fitting, attrs) do
    fitting
    |> cast(attrs, [])
    |> validate_required([])
  end
end
