defmodule QuebradoBankWeb.WelcomeController do
  @moduledoc """
  A simple welcome message from QuebradoBank.
  """
  use QuebradoBankWeb, :controller

  action_fallback(FallbackController)

  @doc "Hello World from API."
  @spec index(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:welcome)
  end
end

