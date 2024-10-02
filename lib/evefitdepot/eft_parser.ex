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
    is_t3_ship = ship_name in @t3_ships

    # Define the order of slots
    slot_keys = ["low", "mid", "high", "rigs"]
    slot_keys = if is_t3_ship, do: slot_keys ++ ["subsystems"], else: slot_keys

    # Initialize slots
    slots = Map.new(slot_keys, fn key -> {key, []} end)
    drones = []
    cargo = []

    acc = %{slots: slots, drones: drones, cargo: cargo, slot_index: 0}

    acc = Enum.reduce(sections, acc, fn section, acc ->
      lines = section |> Enum.map(&String.trim/1) |> Enum.reject(&(&1 == ""))

      if lines == [] do
        # Skip empty sections
        acc
      else
        if Enum.all?(lines, &item_with_quantity?/1) do
          # If drones are empty, assign to drones
          if acc.drones == [] do
            items = parse_items_with_quantity(lines)
            %{acc | drones: acc.drones ++ items}
          else
            # Assign to cargo
            items = parse_items_with_quantity(lines)
            %{acc | cargo: acc.cargo ++ items}
          end
        else
          # Assign to the next slot
          if acc.slot_index < length(slot_keys) do
            slot_key = Enum.at(slot_keys, acc.slot_index)
            modules = parse_module_lines(lines)
            slots = Map.update!(acc.slots, slot_key, &(&1 ++ modules))
            %{acc | slots: slots, slot_index: acc.slot_index + 1}
          else
            # Extra modules beyond expected slots
            acc
          end
        end
      end
    end)

    {acc.slots, acc.drones, acc.cargo}
  end


  defp item_with_quantity?(line) do
    regex = ~r/^.+\s+x\s*\d+$/
    Regex.match?(regex, line)
  end

  defp parse_module_lines(lines) do
    lines
    |> List.flatten()
    |> Enum.map(fn line ->
      [module_name | rest] = String.split(line, ",", parts: 2)
      module_name = String.trim(module_name)
      charge = rest |> List.first() |> (fn x -> x && String.trim(x) end).()

      %{"name" => module_name, "charge" => charge}
    end)
  end



  defp parse_items_with_quantity(lines) do
    Enum.map(lines, fn line ->
      [_, name, quantity_str] = Regex.run(~r/^(.+?)\s+x(\d+)$/, line)
      quantity = String.to_integer(quantity_str)
      %{"name" => name, "quantity" => quantity}
    end)
  end
end
