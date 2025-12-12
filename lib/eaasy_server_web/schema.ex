defmodule EaasyServerWeb.Schema do
  use Absinthe.Schema

  import_types EaasyServerWeb.Schema.CustomTypes
  import_types EaasyServerWeb.Schema.FlightTypes

  alias EaasyServer.Flights

  def context(ctx) do
    loader =
      Dataloader.new()
      |> Dataloader.add_source(Flights, Flights.datasource())

    Map.put(ctx, :loader, loader)
  end

  def plugins do
    [Absinthe.Middleware.Dataloader] ++ Absinthe.Plugin.defaults()
  end

  query do
    @desc "Get all airlines"
    field :airlines, list_of(:airline) do
      resolve &EaasyServerWeb.Resolvers.FlightResolver.list_airlines/3
    end

    @desc "Get an airline by ID"
    field :airline, :airline do
      arg :id, non_null(:id)
      resolve &EaasyServerWeb.Resolvers.FlightResolver.get_airline/3
    end

    @desc "Get all flights"
    field :flights, list_of(:flight) do
      arg :origin, :string
      arg :dest, :string
      arg :carrier, :string
      arg :from_date, :date
      arg :to_date, :date
      arg :limit, :integer, default_value: 100
      arg :offset, :integer, default_value: 0
      resolve &EaasyServerWeb.Resolvers.FlightResolver.list_flights/3
    end

    @desc "Get a flight by ID"
    field :flight, :flight do
      arg :id, non_null(:id)
      resolve &EaasyServerWeb.Resolvers.FlightResolver.get_flight/3
    end
  end

  mutation do
    @desc "Create an airline"
    field :create_airline, :airline do
      arg :name, non_null(:string)
      resolve &EaasyServerWeb.Resolvers.FlightResolver.create_airline/3
    end

    @desc "Create a flight"
    field :create_flight, :flight do
      arg :year, non_null(:integer)
      arg :month, non_null(:integer)
      arg :day, non_null(:integer)
      arg :dep_time, :float
      arg :arr_time, :float
      arg :flight_number, non_null(:string)
      arg :origin, non_null(:string)
      arg :dest, non_null(:string)
      arg :carrier, :string
      arg :airline_id, non_null(:id)
      resolve &EaasyServerWeb.Resolvers.FlightResolver.create_flight/3
    end
  end
end
