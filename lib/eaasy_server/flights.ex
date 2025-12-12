defmodule EaasyServer.Flights do
  @moduledoc """
  The Flights context.
  """

  import Ecto.Query, warn: false
  alias EaasyServer.Repo

  alias EaasyServer.Flights.{Airline, Flight}

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
