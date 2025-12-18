defmodule EaasyServerWeb.Resolvers.FlightResolver do
  alias EaasyServer.Flights

  def list_airlines(_parent, _args, _resolution) do
    {:ok, Flights.list_airlines()}
  end

  def get_airline(_parent, %{id: id}, _resolution) do
    case Flights.get_airline(id) do
      nil -> {:error, "Airline not found"}
      airline -> {:ok, airline}
    end
  end

  def list_flights(_parent, args, _resolution) do
    filters = %{
      origin: Map.get(args, :origin),
      dest: Map.get(args, :dest),
      carrier: Map.get(args, :carrier),
      from_date: Map.get(args, :from_date),
      to_date: Map.get(args, :to_date),
      departure_time: Map.get(args, :departure_time)
    }
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
    |> Map.new()

    opts = [
      limit: Map.get(args, :limit, 100),
      offset: Map.get(args, :offset, 0),
      filters: filters
    ]

    {:ok, Flights.list_flights(opts)}
  end

  def get_flight(_parent, %{id: id}, _resolution) do
    case Flights.get_flight(id) do
      nil -> {:error, "Flight not found"}
      flight -> {:ok, flight}
    end
  end

  def create_airline(_parent, args, _resolution) do
    Flights.create_airline(args)
  end

  def create_flight(_parent, args, _resolution) do
    Flights.create_flight(args)
  end
end
