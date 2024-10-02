defmodule Evefitdepot.ESIClient do
  @moduledoc """
  Client for fetching data from EVE Online's ESI API.
  """
  require Logger

  @base_url "https://esi.evetech.net/latest"

  @doc """
  Resolve item names to type IDs using the POST /universe/ids/ endpoint.
  """
  def get_type_id(item_name) do
    url = "#{@base_url}/universe/ids/"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!([item_name])

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, %{"inventory_types" => inventory_types}} ->
            case Enum.find(inventory_types, fn item -> item["name"] == item_name end) do
              %{"id" => type_id} -> {:ok, type_id}
              _ ->
                Logger.warning("Type ID not found for item: #{item_name}")
                {:error, :not_found}
            end

          _ ->
            Logger.error("Failed to parse response for item: #{item_name}")
            {:error, :not_found}
        end

      {:ok, %{status_code: status_code}} ->
        Logger.error("Failed to fetch type ID for item: #{item_name}, status code: #{status_code}")
        {:error, :not_found}

      {:error, reason} ->
        Logger.error("HTTP error fetching type ID for item: #{item_name}, reason: #{inspect(reason)}")
        {:error, :not_found}
    end
  end

  def get_type_ids(item_names) do
    url = "#{@base_url}/universe/ids/"
    headers = [{"Content-Type", "application/json"}]
    body = Jason.encode!(Enum.uniq(item_names))

    case HTTPoison.post(url, body, headers) do
      {:ok, %{status_code: 200, body: response_body}} ->
        case Jason.decode(response_body) do
          {:ok, data} ->
            # Collect all items from the response
            items =
              data
              |> Map.values()
              |> List.flatten()

            # Create a map of item names to type IDs
            Enum.reduce(items, %{}, fn item, acc ->
              Map.put(acc, item["name"], item["id"])
            end)

          {:error, _reason} ->
            Logger.error("Failed to decode JSON response from ESI API.")
            %{}
        end

      {:ok, %{status_code: status_code}} ->
        Logger.error("Failed to fetch type IDs from ESI API, status code: #{status_code}")
        %{}

      {:error, reason} ->
        Logger.error("HTTP error fetching type IDs from ESI API: #{inspect(reason)}")
        %{}
    end
  end


  def get_item_icon_url(type_id) do
    "https://images.evetech.net/types/#{type_id}/icon"
  end
end
