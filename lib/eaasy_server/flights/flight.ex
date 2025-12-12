defmodule EaasyServer.Flights.Flight do
  use Ecto.Schema
  import Ecto.Changeset

  schema "flights" do
    field :year, :integer
    field :month, :integer
    field :day, :integer
    field :dep_time, :float
    field :arr_time, :float
    field :flight_number, :string
    field :origin, :string
    field :dest, :string
    field :carrier, :string

    belongs_to :airline, EaasyServer.Flights.Airline

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(flight, attrs) do
    flight
    |> cast(attrs, [:year, :month, :day, :dep_time, :arr_time, :flight_number, :origin, :dest, :carrier, :airline_id])
    |> validate_required([:year, :month, :day, :origin, :dest, :flight_number, :airline_id])
    |> validate_number(:year, greater_than: 1900, less_than: 2100)
    |> validate_number(:month, greater_than_or_equal_to: 1, less_than_or_equal_to: 12)
    |> validate_number(:day, greater_than_or_equal_to: 1, less_than_or_equal_to: 31)
    |> foreign_key_constraint(:airline_id)
  end

  @doc """
  Returns a Date struct from the flight's year, month, and day fields.
  """
  def get_date(%__MODULE__{year: year, month: month, day: day}) do
    Date.new(year, month, day)
  end

  @doc """
  Returns a Time struct from a time value (e.g., 517.0 = 5:17).
  The time is stored as a float where the integer part is hours and the decimal part * 100 is minutes.
  """
  def parse_time(nil), do: {:ok, nil}
  def parse_time(time_value) when is_float(time_value) or is_integer(time_value) do
    hours = trunc(time_value / 100)
    minutes = rem(trunc(time_value), 100)
    Time.new(hours, minutes, 0)
  end

  @doc """
  Returns the departure time as a Time struct.
  """
  def get_dep_time(%__MODULE__{dep_time: dep_time}) do
    parse_time(dep_time)
  end

  @doc """
  Returns the arrival time as a Time struct.
  """
  def get_arr_time(%__MODULE__{arr_time: arr_time}) do
    parse_time(arr_time)
  end
end
