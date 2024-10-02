defmodule EvefitdepotWeb.FittingLive.Index do
  use EvefitdepotWeb, :live_view

  alias Evefitdepot.Fittings
  alias Evefitdepot.Fittings.Fitting

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :fittings, Fittings.list_fittings())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Fitting")
    |> assign(:fitting, Fittings.get_fitting!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Fitting")
    |> assign(:fitting, %Fitting{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Fittings")
    |> assign(:fitting, nil)
  end

  @impl true
  def handle_info({EvefitdepotWeb.FittingLive.FormComponent, {:saved, fitting}}, socket) do
    {:noreply, stream_insert(socket, :fittings, fitting)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    fitting = Fittings.get_fitting!(id)
    {:ok, _} = Fittings.delete_fitting(fitting)

    {:noreply, stream_delete(socket, :fittings, fitting)}
  end
end
