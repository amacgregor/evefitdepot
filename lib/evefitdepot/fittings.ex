defmodule Evefitdepot.Fittings do
  @moduledoc """
  The Fittings context.
  """

  import Ecto.Query, warn: false
  alias Evefitdepot.Repo

  alias Evefitdepot.Fittings.Fitting

  @doc """
  Returns the list of fittings.

  ## Examples

      iex> list_fittings()
      [%Fitting{}, ...]

  """
  def list_fittings do
    Repo.all(Fitting)
  end

  @doc """
  Gets a single fitting.

  Raises `Ecto.NoResultsError` if the Fitting does not exist.

  ## Examples

      iex> get_fitting!(123)
      %Fitting{}

      iex> get_fitting!(456)
      ** (Ecto.NoResultsError)

  """
  def get_fitting!(id), do: Repo.get!(Fitting, id)

  @doc """
  Creates a fitting.

  ## Examples

      iex> create_fitting(%{field: value})
      {:ok, %Fitting{}}

      iex> create_fitting(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_fitting(attrs \\ %{}) do
    %Fitting{}
    |> Fitting.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a fitting.

  ## Examples

      iex> update_fitting(fitting, %{field: new_value})
      {:ok, %Fitting{}}

      iex> update_fitting(fitting, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_fitting(%Fitting{} = fitting, attrs) do
    fitting
    |> Fitting.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a fitting.

  ## Examples

      iex> delete_fitting(fitting)
      {:ok, %Fitting{}}

      iex> delete_fitting(fitting)
      {:error, %Ecto.Changeset{}}

  """
  def delete_fitting(%Fitting{} = fitting) do
    Repo.delete(fitting)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking fitting changes.

  ## Examples

      iex> change_fitting(fitting)
      %Ecto.Changeset{data: %Fitting{}}

  """
  def change_fitting(%Fitting{} = fitting, attrs \\ %{}) do
    Fitting.changeset(fitting, attrs)
  end
end
