defmodule EaasyServer.Repo.Migrations.CreateFlights do
  use Ecto.Migration

  def change do
    create table(:flights) do
      add :year, :integer, null: false
      add :month, :integer, null: false
      add :day, :integer, null: false
      add :dep_time, :float
      add :arr_time, :float
      add :flight_number, :string, null: false
      add :origin, :string, null: false
      add :dest, :string, null: false
      add :carrier, :string
      add :airline_id, references(:airlines, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:flights, [:airline_id])
    create index(:flights, [:origin])
    create index(:flights, [:dest])
    create index(:flights, [:year, :month, :day])
  end
end
