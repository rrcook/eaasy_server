defmodule EaasyServer.Flights.Airline do
  use Ecto.Schema
  import Ecto.Changeset

  schema "airlines" do
    field :name, :string

    has_many :flights, EaasyServer.Flights.Flight

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(airline, attrs) do
    airline
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
