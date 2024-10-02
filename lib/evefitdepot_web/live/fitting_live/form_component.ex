defmodule EvefitdepotWeb.FittingLive.FormComponent do
  use EvefitdepotWeb, :live_component

  alias Evefitdepot.Fittings

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage fitting records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="fitting-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >

        <:actions>
          <.button phx-disable-with="Saving...">Save Fitting</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{fitting: fitting} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Fittings.change_fitting(fitting))
     end)}
  end

  @impl true
  def handle_event("validate", %{"fitting" => fitting_params}, socket) do
    changeset = Fittings.change_fitting(socket.assigns.fitting, fitting_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"fitting" => fitting_params}, socket) do
    save_fitting(socket, socket.assigns.action, fitting_params)
  end

  defp save_fitting(socket, :edit, fitting_params) do
    case Fittings.update_fitting(socket.assigns.fitting, fitting_params) do
      {:ok, fitting} ->
        notify_parent({:saved, fitting})

        {:noreply,
         socket
         |> put_flash(:info, "Fitting updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_fitting(socket, :new, fitting_params) do
    case Fittings.create_fitting(fitting_params) do
      {:ok, fitting} ->
        notify_parent({:saved, fitting})

        {:noreply,
         socket
         |> put_flash(:info, "Fitting created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
