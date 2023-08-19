defmodule QuebradoBank.Repo do
  use Ecto.Repo,
    otp_app: :quebrado_bank,
    adapter: Ecto.Adapters.Postgres
end
