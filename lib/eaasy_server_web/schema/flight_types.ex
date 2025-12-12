defmodule EaasyServerWeb.Schema.FlightTypes do
  use Absinthe.Schema.Notation
  import Absinthe.Resolution.Helpers, only: [dataloader: 1]

  alias EaasyServer.Flights

  @desc "An airline"
  object :airline do
    field :id, non_null(:id)
    field :name, non_null(:string)
    field :flights, list_of(:flight), resolve: dataloader(Flights)
    field :inserted_at, non_null(:string)
    field :updated_at, non_null(:string)
  end

  @desc "A flight"
  object :flight do
    field :id, non_null(:id)
    field :year, non_null(:integer)
    field :month, non_null(:integer)
    field :day, non_null(:integer)
    field :dep_time, :float
    field :arr_time, :float
    field :flight_number, non_null(:string)
    field :origin, non_null(:string)
    field :dest, non_null(:string)
    field :carrier, :string
    field :airline_id, non_null(:id)
    field :airline, non_null(:airline), resolve: dataloader(Flights)
    field :inserted_at, non_null(:string)
    field :updated_at, non_null(:string)

    @desc "The flight date derived from year, month, and day"
    field :date, :date do
      resolve fn flight, _args, _context ->
        case EaasyServer.Flights.Flight.get_date(flight) do
          {:ok, date} -> {:ok, date}
          {:error, _} -> {:ok, nil}
        end
      end
    end

    @desc "The departure time"
    field :departure_time, :time do
      resolve fn flight, _args, _context ->
        EaasyServer.Flights.Flight.get_dep_time(flight)
      end
    end

    @desc "The arrival time"
    field :arrival_time, :time do
      resolve fn flight, _args, _context ->
        EaasyServer.Flights.Flight.get_arr_time(flight)
      end
    end
  end
end
