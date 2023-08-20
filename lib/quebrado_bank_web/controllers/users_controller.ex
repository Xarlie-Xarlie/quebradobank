defmodule QuebradoBankWeb.UsersController do
  @moduledoc """
  Users Controller.

  Handle with create, update, read, delete users.
  """
  use QuebradoBankWeb, :controller

  alias Ecto.Changeset
  alias QuebradoBank.Users.Create
  alias QuebradoBank.Users.User

  def create(conn, params) do
    params
    |> Create.call()
    |> handle_response(conn)
  end

  defp handle_response({:ok, %User{} = user}, conn) do
    conn
    |> put_status(:created)
    |> render(:create, user: user)
  end

  defp handle_response({:error, %Changeset{} = changeset}, conn) do
    conn
    |> put_status(:bad_request)
    |> put_view(json: QuebradoBankWeb.ErrorJSON)
    |> render(:error, changeset: changeset)
  end
end
