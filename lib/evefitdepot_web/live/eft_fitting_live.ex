defmodule EvefitdepotWeb.EFTFittingLive do
  use EvefitdepotWeb, :live_view
  require Logger

  alias Evefitdepot.EFTParser
  alias Evefitdepot.ESIClient

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       eft_text: "",
       parsed_fitting: nil,
       error: nil
     )}
  end

  def handle_event("parse_eft", %{"eft_text" => eft_text}, socket) do
    try do
      parsed_fitting = EFTParser.parse(eft_text)

      if parsed_fitting["ship"] == "Unknown Ship" do
        {:noreply,
         assign(socket,
           eft_text: eft_text,
           parsed_fitting: nil,
           error: "Invalid EFT fitting format."
         )}
      else
        # Fetch type IDs and icons
        parsed_fitting = fetch_type_ids_and_icons(parsed_fitting)

        {:noreply,
         assign(socket,
           eft_text: eft_text,
           parsed_fitting: parsed_fitting,
           error: nil
         )}
      end
    rescue
      e ->
        Logger.error("Error parsing fitting: #{inspect(e)}")
        {:noreply,
         assign(socket,
           eft_text: eft_text,
           parsed_fitting: nil,
           error: "An error occurred while parsing the fitting."
         )}
    end
  end

  defp fetch_type_ids_and_icons(parsed_fitting) do
    # Fetch ship type ID and image
    ship_name = parsed_fitting["ship"]

    IO.inspect(parsed_fitting)

    ship =
      with {:ok, type_id} <- Evefitdepot.ESIClient.get_type_id(ship_name),
           icon_url = Evefitdepot.ESIClient.get_item_icon_url(type_id) do
        %{
          "name" => ship_name,
          "type_id" => type_id,
          "image_url" => icon_url
        }
      else
        _ ->
          %{"name" => ship_name}
      end

    parsed_fitting = Map.put(parsed_fitting, "ship", ship)

    # Collect all item names
    module_names =
      parsed_fitting["slots"]
      |> Enum.flat_map(fn {_slot_type, modules} -> Enum.map(modules, & &1["name"]) end)

    IO.inspect(module_names)

    drone_names = Enum.map(parsed_fitting["drones"], & &1["name"])
    cargo_names = Enum.map(parsed_fitting["cargo"], & &1["name"])
    all_item_names = module_names ++ drone_names ++ cargo_names
    IO.inspect(all_item_names)

    # Fetch all type IDs at once using the ESIClient
    type_id_map = Evefitdepot.ESIClient.get_type_ids(all_item_names)

      IO.inspect(type_id_map)
    # Update modules
    parsed_fitting = Map.update!(parsed_fitting, "slots", fn slots ->
      Enum.map(slots, fn {slot_type, modules} ->
        updated_modules =
          Enum.map(modules, fn module ->
            if type_id = Map.get(type_id_map, module["name"]) do
              icon_url = Evefitdepot.ESIClient.get_item_icon_url(type_id)
              module
              |> Map.put("icon_url", icon_url)
              |> Map.put("type_id", type_id)
            else
              module
            end
          end)

        {slot_type, updated_modules}
      end)
      |> Enum.into(%{})
    end)

    # Update drones
    parsed_fitting = Map.update!(parsed_fitting, "drones", fn drones ->
      Enum.map(drones, fn drone ->
        if type_id = Map.get(type_id_map, drone["name"]) do
          icon_url = Evefitdepot.ESIClient.get_item_icon_url(type_id)
          drone
          |> Map.put("icon_url", icon_url)
          |> Map.put("type_id", type_id)
        else
          drone
        end
      end)
    end)

    # Update cargo
    parsed_fitting = Map.update!(parsed_fitting, "cargo", fn cargo ->
      Enum.map(cargo, fn item ->
        if type_id = Map.get(type_id_map, item["name"]) do
          icon_url = Evefitdepot.ESIClient.get_item_icon_url(type_id)
          item
          |> Map.put("icon_url", icon_url)
          |> Map.put("type_id", type_id)
        else
          item
        end
      end)
    end)
    IO.inspect(parsed_fitting)

    parsed_fitting
  end

end
