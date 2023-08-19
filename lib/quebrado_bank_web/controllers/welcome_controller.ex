defmodule QuebradoBankWeb.WelcomeController do
  use QuebradoBankWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> json(%{message: "Welcome to Quebrado Bank", status: :ok})
  end
end
