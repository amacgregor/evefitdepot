defmodule Evefitdepot.FittingsTest do
  use Evefitdepot.DataCase

  alias Evefitdepot.Fittings

  describe "fittings" do
    alias Evefitdepot.Fittings.Fitting

    import Evefitdepot.FittingsFixtures

    @invalid_attrs %{}

    test "list_fittings/0 returns all fittings" do
      fitting = fitting_fixture()
      assert Fittings.list_fittings() == [fitting]
    end

    test "get_fitting!/1 returns the fitting with given id" do
      fitting = fitting_fixture()
      assert Fittings.get_fitting!(fitting.id) == fitting
    end

    test "create_fitting/1 with valid data creates a fitting" do
      valid_attrs = %{}

      assert {:ok, %Fitting{} = fitting} = Fittings.create_fitting(valid_attrs)
    end

    test "create_fitting/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Fittings.create_fitting(@invalid_attrs)
    end

    test "update_fitting/2 with valid data updates the fitting" do
      fitting = fitting_fixture()
      update_attrs = %{}

      assert {:ok, %Fitting{} = fitting} = Fittings.update_fitting(fitting, update_attrs)
    end

    test "update_fitting/2 with invalid data returns error changeset" do
      fitting = fitting_fixture()
      assert {:error, %Ecto.Changeset{}} = Fittings.update_fitting(fitting, @invalid_attrs)
      assert fitting == Fittings.get_fitting!(fitting.id)
    end

    test "delete_fitting/1 deletes the fitting" do
      fitting = fitting_fixture()
      assert {:ok, %Fitting{}} = Fittings.delete_fitting(fitting)
      assert_raise Ecto.NoResultsError, fn -> Fittings.get_fitting!(fitting.id) end
    end

    test "change_fitting/1 returns a fitting changeset" do
      fitting = fitting_fixture()
      assert %Ecto.Changeset{} = Fittings.change_fitting(fitting)
    end
  end
end
