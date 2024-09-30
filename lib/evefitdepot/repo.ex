defmodule Evefitdepot.Repo do
  use Ecto.Repo,
    otp_app: :evefitdepot,
    adapter: Ecto.Adapters.Postgres
end
