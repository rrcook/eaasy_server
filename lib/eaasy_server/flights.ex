defmodule EaasyServer.Flights do
  @moduledoc """
  The Flights context.
  """

  import Ecto.Query, warn: false
  alias EaasyServer.Repo

  alias EaasyServer.Flights.{Airline, Flight}

  @flight_time_offset 60

  @doc """
  Returns the list of airlines.

  ## Examples

      iex> list_airlines()
      [%Airline{}, ...]

  """
  def list_airlines do
    Repo.all(Airline)
  end

  @doc """
  Gets a single airline.

  Raises `Ecto.NoResultsError` if the Airline does not exist.

  ## Examples

      iex> get_airline!(123)
      %Airline{}

      iex> get_airline!(456)
      ** (Ecto.NoResultsError)

  """
  def get_airline!(id), do: Repo.get!(Airline, id)

  @doc """
  Gets a single airline.

  Returns `nil` if the Airline does not exist.

  ## Examples

      iex> get_airline(123)
      %Airline{}

      iex> get_airline(456)
      nil

  """
  def get_airline(id), do: Repo.get(Airline, id)

  @doc """
  Creates an airline.

  ## Examples

      iex> create_airline(%{field: value})
      {:ok, %Airline{}}

      iex> create_airline(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_airline(attrs \\ %{}) do
    %Airline{}
    |> Airline.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates an airline.

  ## Examples

      iex> update_airline(airline, %{field: new_value})
      {:ok, %Airline{}}

      iex> update_airline(airline, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_airline(%Airline{} = airline, attrs) do
    airline
    |> Airline.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes an airline.

  ## Examples

      iex> delete_airline(airline)
      {:ok, %Airline{}}

      iex> delete_airline(airline)
      {:error, %Ecto.Changeset{}}

  """
  def delete_airline(%Airline{} = airline) do
    Repo.delete(airline)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking airline changes.

  ## Examples

      iex> change_airline(airline)
      %Ecto.Changeset{data: %Airline{}}

  """
  def change_airline(%Airline{} = airline, attrs \\ %{}) do
    Airline.changeset(airline, attrs)
  end

  @doc """
  Returns the list of flights.

  ## Examples

      iex> list_flights()
      [%Flight{}, ...]

      iex> list_flights(filters: %{origin: "JFK"})
      [%Flight{origin: "JFK"}, ...]

      iex> list_flights(filters: %{origin: "JFK", carrier: "UA"})
      [%Flight{origin: "JFK", carrier: "UA"}, ...]

  """
  def list_flights(opts \\ []) do
    limit = Keyword.get(opts, :limit, 100)
    offset = Keyword.get(opts, :offset, 0)
    filters = Keyword.get(opts, :filters, %{})

    Flight
    |> apply_filters(filters)
    |> limit(^limit)
    |> offset(^offset)
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, acc ->
      case key do
        :origin -> where(acc, [f], f.origin == ^value)
        :dest -> where(acc, [f], f.dest == ^value)
        :carrier -> where(acc, [f], f.carrier == ^value)
        :from_date -> filter_from_date(acc, value)
        :to_date -> filter_to_date(acc, value)
        :departure_time -> filter_departure_time(acc, value)
        _ -> acc
      end
    end)
  end

  defp filter_from_date(query, %Date{} = from_date) do
    where(query, [f],
      fragment("make_date(?, ?, ?)", f.year, f.month, f.day) >= ^from_date
    )
  end

  defp filter_to_date(query, %Date{} = to_date) do
    where(query, [f],
      fragment("make_date(?, ?, ?)", f.year, f.month, f.day) <= ^to_date
    )
  end

  defp filter_departure_time(query, time_string) when is_binary(time_string) do
    case parse_time_to_numeric(time_string) do
      {:ok, numeric_time} ->
        earliest_time = adjust_time(numeric_time, -@flight_time_offset)
        latest_time = adjust_time(numeric_time, @flight_time_offset)
        where(query, [f], f.dep_time >= ^earliest_time and f.dep_time <= ^latest_time)
      {:error, _} -> query
    end
  end

  defp parse_time_to_numeric(time_string) do
    case String.split(time_string, ":") do
      [hours, minutes] ->
        with {h, ""} <- Integer.parse(hours),
             {m, ""} <- Integer.parse(minutes),
             true <- h >= 0 and h <= 23,
             true <- m >= 0 and m <= 59 do
          {:ok, trunc(h * 100.0 + m)}
        else
          _ -> {:error, :invalid_time}
        end
      _ -> {:error, :invalid_format}
    end
  end

  @doc """
  Adjusts a time value by a given offset in minutes.

  ## Parameters
    - time: Integer where thousands/hundreds places represent hours (0-23)
            and tens/ones places represent minutes (0-59)
    - offset: Number of minutes to add (positive) or subtract (negative)

  ## Examples

      iex> adjust_time(830, 15)
      845

      iex> adjust_time(830, -45)
      745

      iex> adjust_time(2345, 30)
      15

      iex> adjust_time(100, -90)
      2330

  """
  def adjust_time(time, offset) when is_integer(time) and is_integer(offset) do
    # Extract hours and minutes from the time integer
    hours = div(time, 100)
    minutes = rem(time, 100)

    # Convert to total minutes
    total_minutes = hours * 60 + minutes

    # Add the offset
    adjusted_minutes = total_minutes + offset

    # Handle wrapping around 24 hours (1440 minutes)
    # Use rem to handle negative values correctly
    normalized_minutes = rem(adjusted_minutes, 1440)
    normalized_minutes = if normalized_minutes < 0, do: normalized_minutes + 1440, else: normalized_minutes

    # Convert back to hours and minutes
    new_hours = div(normalized_minutes, 60)
    new_minutes = rem(normalized_minutes, 60)

    # Return in original format
    new_hours * 100 + new_minutes
  end

  @doc """
  Gets a single flight.

  Raises `Ecto.NoResultsError` if the Flight does not exist.

  ## Examples

      iex> get_flight!(123)
      %Flight{}

      iex> get_flight!(456)
      ** (Ecto.NoResultsError)

  """
  def get_flight!(id), do: Repo.get!(Flight, id)

  @doc """
  Gets a single flight.

  Returns `nil` if the Flight does not exist.

  ## Examples

      iex> get_flight(123)
      %Flight{}

      iex> get_flight(456)
      nil

  """
  def get_flight(id), do: Repo.get(Flight, id)

  @doc """
  Creates a flight.

  ## Examples

      iex> create_flight(%{field: value})
      {:ok, %Flight{}}

      iex> create_flight(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_flight(attrs \\ %{}) do
    %Flight{}
    |> Flight.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a flight.

  ## Examples

      iex> update_flight(flight, %{field: new_value})
      {:ok, %Flight{}}

      iex> update_flight(flight, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_flight(%Flight{} = flight, attrs) do
    flight
    |> Flight.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a flight.

  ## Examples

      iex> delete_flight(flight)
      {:ok, %Flight{}}

      iex> delete_flight(flight)
      {:error, %Ecto.Changeset{}}

  """
  def delete_flight(%Flight{} = flight) do
    Repo.delete(flight)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking flight changes.

  ## Examples

      iex> change_flight(flight)
      %Ecto.Changeset{data: %Flight{}}

  """
  def change_flight(%Flight{} = flight, attrs \\ %{}) do
    Flight.changeset(flight, attrs)
  end

  @doc """
  Dataloader source for Flights context
  """
  def datasource do
    Dataloader.Ecto.new(Repo, query: &query/2)
  end

  def query(queryable, _params) do
    queryable
  end
end
