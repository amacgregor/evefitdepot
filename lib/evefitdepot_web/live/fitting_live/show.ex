defmodule EvefitdepotWeb.FittingLive.Show do
  use EvefitdepotWeb, :live_view

  alias Evefitdepot.Fittings

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:fitting, Fittings.get_fitting!(id))}
  end

  defp page_title(:show), do: "Show Fitting"
  defp page_title(:edit), do: "Edit Fitting"
end
