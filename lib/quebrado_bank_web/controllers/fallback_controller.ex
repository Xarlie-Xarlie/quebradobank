defmodule QuebradoBankWeb.FallbackController do
  @moduledoc """
  Fallback Controller.

  call when controller could not resolve an error/fallback.
  """
  use QuebradoBankWeb, :controller

  alias Ecto.Changeset
  alias QuebradoBankWeb.ErrorJSON

  @doc """
  Default fallback controller response.

  ## Examples:
    iex> #{__MODULE__}.call(
      conn,
      {:error, changeset}
    )
    %Plug.Conn{status: 400}
  """
  @spec call(Plug.Conn.t(), {:error, Changeset.t()}) :: Plug.Conn.t()
  def call(conn, {:error, %Changeset{} = changeset}) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
