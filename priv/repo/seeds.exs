# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     EaasyServer.Repo.insert!(%EaasyServer.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias EaasyServer.Repo
alias EaasyServer.Flights.{Airline, Flight}

# Path to the CSV file
csv_file = Path.join(:code.priv_dir(:eaasy_server), "../data/flights.csv")

IO.puts("Starting to seed database from #{csv_file}...")
IO.puts("This may take a while for large files...")

# Clear existing data
IO.puts("Clearing existing flights...")
Repo.delete_all(Flight)
IO.puts("Clearing existing airlines...")
Repo.delete_all(Airline)

# Parse CSV and load airlines first
IO.puts("Processing airlines...")

airline_names =
  csv_file
  |> File.stream!()
  |> Stream.drop(1) # Skip header
  |> Stream.map(fn line ->
    # Simple CSV parsing - split by comma
    line
    |> String.trim()
    |> String.split(",")
    |> List.last() # The airline name is the last column
  end)
  |> Enum.uniq()
  |> Enum.reject(&is_nil/1)

# Insert airlines
airlines =
  airline_names
  |> Enum.map(fn name ->
    %{
      name: name,
      inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
      updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
    }
  end)

{airline_count, _} = Repo.insert_all(Airline, airlines)
IO.puts("Inserted #{airline_count} airlines")

# Create a map of airline name to airline id for quick lookup
airline_map =
  Airline
  |> Repo.all()
  |> Enum.into(%{}, fn airline -> {airline.name, airline.id} end)

IO.puts("Processing flights...")

# Process flights in batches
batch_size = 1000
flight_count = 0

csv_file
|> File.stream!()
|> Stream.drop(1) # Skip header
|> Stream.map(fn line ->
  # Parse CSV line
  fields =
    line
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.trim/1)

  # Map fields based on CSV structure:
  # id,year,month,day,dep_time,sched_dep_time,dep_delay,arr_time,sched_arr_time,arr_delay,
  # carrier,flight,tailnum,origin,dest,air_time,distance,hour,minute,time_hour,name
  [_id, year, month, day, dep_time, _sched_dep_time, _dep_delay, arr_time, _sched_arr_time,
   _arr_delay, carrier, flight_num, _tailnum, origin, dest, _air_time, _distance, _hour,
   _minute, _time_hour, airline_name] = fields

  # Helper to parse float or nil
  parse_float = fn
    "" -> nil
    val -> String.to_float(val)
  end

  # Helper to parse integer
  parse_int = fn val ->
    String.to_integer(val)
  end

  %{
    year: parse_int.(year),
    month: parse_int.(month),
    day: parse_int.(day),
    dep_time: parse_float.(dep_time),
    arr_time: parse_float.(arr_time),
    flight_number: flight_num,
    origin: origin,
    dest: dest,
    carrier: carrier,
    airline_id: Map.get(airline_map, airline_name),
    inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
    updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
  }
end)
|> Stream.chunk_every(batch_size)
|> Enum.each(fn batch ->
  {count, _} = Repo.insert_all(Flight, batch)
  flight_count = flight_count + count
  IO.write(".")
end)

IO.puts("")
IO.puts("Seeding complete!")
IO.puts("Total flights inserted: Check database for count")
