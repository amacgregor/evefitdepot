defmodule EvefitdepotWeb.FittingLiveTest do
  use EvefitdepotWeb.ConnCase

  import Phoenix.LiveViewTest
  import Evefitdepot.FittingsFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_fitting(_) do
    fitting = fitting_fixture()
    %{fitting: fitting}
  end

  describe "Index" do
    setup [:create_fitting]

    test "lists all fittings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/fittings")

      assert html =~ "Listing Fittings"
    end

    test "saves new fitting", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/fittings")

      assert index_live |> element("a", "New Fitting") |> render_click() =~
               "New Fitting"

      assert_patch(index_live, ~p"/fittings/new")

      assert index_live
             |> form("#fitting-form", fitting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fitting-form", fitting: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fittings")

      html = render(index_live)
      assert html =~ "Fitting created successfully"
    end

    test "updates fitting in listing", %{conn: conn, fitting: fitting} do
      {:ok, index_live, _html} = live(conn, ~p"/fittings")

      assert index_live |> element("#fittings-#{fitting.id} a", "Edit") |> render_click() =~
               "Edit Fitting"

      assert_patch(index_live, ~p"/fittings/#{fitting}/edit")

      assert index_live
             |> form("#fitting-form", fitting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#fitting-form", fitting: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/fittings")

      html = render(index_live)
      assert html =~ "Fitting updated successfully"
    end

    test "deletes fitting in listing", %{conn: conn, fitting: fitting} do
      {:ok, index_live, _html} = live(conn, ~p"/fittings")

      assert index_live |> element("#fittings-#{fitting.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#fittings-#{fitting.id}")
    end
  end

  describe "Show" do
    setup [:create_fitting]

    test "displays fitting", %{conn: conn, fitting: fitting} do
      {:ok, _show_live, html} = live(conn, ~p"/fittings/#{fitting}")

      assert html =~ "Show Fitting"
    end

    test "updates fitting within modal", %{conn: conn, fitting: fitting} do
      {:ok, show_live, _html} = live(conn, ~p"/fittings/#{fitting}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Fitting"

      assert_patch(show_live, ~p"/fittings/#{fitting}/show/edit")

      assert show_live
             |> form("#fitting-form", fitting: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#fitting-form", fitting: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/fittings/#{fitting}")

      html = render(show_live)
      assert html =~ "Fitting updated successfully"
    end
  end
end
