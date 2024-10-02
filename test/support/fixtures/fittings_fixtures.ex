defmodule Evefitdepot.FittingsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Evefitdepot.Fittings` context.
  """

  @doc """
  Generate a fitting.
  """
  def fitting_fixture(attrs \\ %{}) do
    {:ok, fitting} =
      attrs
      |> Enum.into(%{

      })
      |> Evefitdepot.Fittings.create_fitting()

    fitting
  end
end
