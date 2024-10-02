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
        image_url = Evefitdepot.ESIClient.get_ship_render_url(type_id) do
        # Fetch ship attributes
        ship_attributes = Evefitdepot.ESIClient.get_ship_attributes(type_id)

        %{
          "name" => ship_name,
          "type_id" => type_id,
          "image_url" => image_url
        }
        |> Map.merge(ship_attributes)
      else
        _ ->
          %{"name" => ship_name}
      end

    parsed_fitting = Map.put(parsed_fitting, "ship", ship)

    # Collect all item names including charges
    module_names_and_charges =
      parsed_fitting["slots"]
      |> Enum.flat_map(fn {_slot_type, modules} ->
        Enum.flat_map(modules, fn module ->
          names = [module["name"]]
          if module["charge"], do: names ++ [module["charge"]], else: names
        end)
      end)

    drone_names = Enum.map(parsed_fitting["drones"], & &1["name"])
    cargo_names = Enum.map(parsed_fitting["cargo"], & &1["name"])
    all_item_names = module_names_and_charges ++ drone_names ++ cargo_names

    # Fetch all type IDs at once using the ESIClient
    type_id_map = Evefitdepot.ESIClient.get_type_ids(all_item_names)

    # Update modules
    parsed_fitting = Map.update!(parsed_fitting, "slots", fn slots ->
      Enum.map(slots, fn {slot_type, modules} ->
        updated_modules =
          Enum.map(modules, fn module ->
            # Update module type ID and icon URL
            module =
              if type_id = Map.get(type_id_map, module["name"]) do
                icon_url = Evefitdepot.ESIClient.get_item_icon_url(type_id)
                module
                |> Map.put("icon_url", icon_url)
                |> Map.put("type_id", type_id)
              else
                module
              end

            # Update charge type ID and icon URL
            charge_name = module["charge"]
            charge_type_id = charge_name && Map.get(type_id_map, charge_name)

            module =
              if charge_type_id do
                icon_url = Evefitdepot.ESIClient.get_item_icon_url(charge_type_id)
                module
                |> Map.put("charge_icon_url", icon_url)
                |> Map.put("charge_type_id", charge_type_id)
              else
                module
              end

            module
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

    parsed_fitting
  end


  defp slot_position(slot_type, index) do
    outer_radius = 180.0
    inner_radius = 130.0

    {angle, radius}  =
      case slot_type do
        "high" ->
          max_slots = 8
          start_angle = -150.0
          end_angle = -60.0
          angle = calculate_angle(index, max_slots, start_angle, end_angle)
          {angle, outer_radius}

        "mid" ->
          max_slots = 8
          start_angle = -45.0
          end_angle = 45.0
          angle = calculate_angle(index, max_slots, start_angle, end_angle)
          {angle, outer_radius}

        "low" ->
          max_slots = 8
          start_angle = 60.0
          end_angle = 150.0
          angle = calculate_angle(index, max_slots, start_angle, end_angle)
          {angle, outer_radius}


        "rigs" ->
          rig_angles = [167.0, 180.0, -167.0] # Positions at left side
          angle = Enum.at(rig_angles, index - 1, 180.0)
          {angle, outer_radius}

        "subsystems" ->
          max_slots = 5
          start_angle =30.0
          end_angle = 100.0
          angle = calculate_angle(index, max_slots, start_angle, end_angle)
          {angle, inner_radius}

          _ ->
            {0.0, outer_radius}
        end

      x = radius * :math.cos(:math.pi() * angle / 180.0)
      y = radius * :math.sin(:math.pi() * angle / 180.0)

      "left: calc(50% + #{x}px - 20px); top: calc(50% + #{y}px - 20px);"

  end

  defp get_all_modules_with_charges(parsed_fitting) do
    parsed_fitting["slots"]
    |> Map.values()
    |> List.flatten()
    |> Enum.map(fn module ->
      module
    end)
  end


  defp calculate_angle(index, max_slots, start_angle, end_angle) do
    if max_slots > 1 do
      angle_increment = (end_angle - start_angle) / (max_slots - 1)
      start_angle + (index - 1) * angle_increment
    else
      start_angle
    end
  end

  defp complete_slots(slot_type, modules) do
    max_slots =
      case slot_type do
        "high" -> 8
        "mid" -> 8
        "low" -> 8
        "rigs" -> 3
        "subsystems" -> 5
        _ -> length(modules || [])
      end

    modules = modules || []
    filled_slots = Enum.take(modules, max_slots)
    empty_slots = List.duplicate(nil, max_slots - length(filled_slots))
    filled_slots ++ empty_slots
  end


  defp module_icon_url(module, slot_type) do
    if module do
      module["icon_url"]
    else
      "/images/empty_#{slot_type}_slot.png"
    end
  end

  defp module_name(module, slot_type) do
    if module do
      module["name"]
    else
      "Empty #{String.capitalize(slot_type)} Slot"
    end
  end
end
