defmodule Evefitdepot.EFTParser do
  @moduledoc """
  Parses EFT fitting text into a structured format.
  """

  @t3_ships ["Legion", "Tengu", "Proteus", "Loki"]

  def parse(eft_text) do
    # Split the text into lines
    lines = String.split(eft_text, ~r/\r?\n/, trim: false)
    [header_line | rest_lines] = lines

    {ship_name, fitting_name} = parse_header(header_line)

    # Split the rest into sections based on blank lines
    sections = split_into_sections(rest_lines)

    # Assign sections to slots, passing the ship_name
    {slots, drones, cargo} = assign_sections(sections, ship_name)

    %{
      "ship" => ship_name,
      "fitting_name" => fitting_name,
      "slots" => slots,
      "drones" => drones,
      "cargo" => cargo
    }
  end

  defp parse_header(header_line) do
    regex = ~r/^\[(.+?),\s*(.+)\]$/
    case Regex.run(regex, header_line) do
      [_, ship_name, fitting_name] -> {ship_name, fitting_name}
      _ -> {"Unknown Ship", "Unnamed Fitting"}
    end
  end

  defp split_into_sections(lines) do
    lines
    |> Enum.chunk_by(&(&1 == ""))
    |> Enum.reject(&(&1 == [""]))
  end

  defp assign_sections(sections, ship_name) do
    # Determine if the ship is a T3 ship
    is_t3_ship = ship_name in @t3_ships

    # Define the order of slots
    slot_keys = ["low", "mid", "high", "rigs"]
    slot_keys = if is_t3_ship, do: slot_keys ++ ["subsystems"], else: slot_keys

    # Initialize slots
    slots = Map.new(slot_keys, fn key -> {key, []} end)

    # Assign sections to slots
    module_section_count = length(slot_keys)
    module_sections = Enum.take(sections, module_section_count)
    remaining_sections = Enum.drop(sections, module_section_count)

    slots = Enum.zip(slot_keys, module_sections)
    |> Enum.reduce(slots, fn {key, lines}, acc ->
      modules = parse_module_lines(lines)
      Map.put(acc, key, modules)
    end)

    # Parse drones and cargo from remaining sections
    {drones, cargo} = parse_drones_and_cargo(remaining_sections)

    {slots, drones, cargo}
  end

  defp parse_module_lines(lines) do
    lines
    |> List.flatten()
    |> Enum.map(fn line ->
      [module_name | rest] = String.split(line, ",", parts: 2)
      module_name = String.trim(module_name)
      charge = rest |> List.first() |> (fn x -> x && String.trim(x) end).()

      %{name: module_name, charge: charge}
    end)
  end

  defp parse_drones_and_cargo(sections) do
    # Initialize drones and cargo
    drones = []
    cargo = []

    # Determine if sections contain drones or cargo
    Enum.reduce(sections, {drones, cargo}, fn section, {drones_acc, cargo_acc} ->
      items = parse_items_with_quantity(section)

      if drones_acc == [] do
        # First section after modules is drones
        {drones_acc ++ items, cargo_acc}
      else
        # Remaining sections are cargo
        {drones_acc, cargo_acc ++ items}
      end
    end)
  end

  defp parse_items_with_quantity(lines) do
    lines
    |> Enum.map(&String.trim/1)
    |> Enum.map(fn line ->
      case parse_item_with_quantity(line) do
        {:ok, item} -> item
        :error -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp parse_item_with_quantity(line) do
    regex = ~r/^(.+?)\s*x\s*(\d+)$/
    case Regex.run(regex, line) do
      [_, item_name, quantity_str] ->
        quantity = String.to_integer(quantity_str)
        {:ok, %{name: item_name, quantity: quantity}}
      _ ->
        :error
    end
  end
end
