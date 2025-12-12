defmodule EaasyServerWeb.Schema.CustomTypes do
  use Absinthe.Schema.Notation

  @desc "A date scalar type"
  scalar :date, name: "Date" do
    description "An ISO 8601 date (YYYY-MM-DD)"

    serialize &Date.to_iso8601/1

    parse fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case Date.from_iso8601(value) do
          {:ok, date} -> {:ok, date}
          _error -> :error
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end
  end

  @desc "A time scalar type"
  scalar :time, name: "Time" do
    description "An ISO 8601 time (HH:MM:SS)"

    serialize &Time.to_iso8601/1

    parse fn
      %Absinthe.Blueprint.Input.String{value: value} ->
        case Time.from_iso8601(value) do
          {:ok, time} -> {:ok, time}
          _error -> :error
        end

      %Absinthe.Blueprint.Input.Null{} ->
        {:ok, nil}

      _ ->
        :error
    end
  end
end
