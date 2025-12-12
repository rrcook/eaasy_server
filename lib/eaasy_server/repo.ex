defmodule EaasyServer.Repo do
  use Ecto.Repo,
    otp_app: :eaasy_server,
    adapter: Ecto.Adapters.Postgres
end
