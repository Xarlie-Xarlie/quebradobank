defmodule QuebradoBankWeb.UsersController do
  @moduledoc """
  Users Controller.

  Handle with create, update, read, delete users.
  """
  use QuebradoBankWeb, :controller

  alias QuebradoBankWeb.FallbackController
  alias QuebradoBank.Users.User
  alias QuebradoBank.Users.Create

  action_fallback FallbackController

  @doc """
  Create a new user.

  Returns JSON response with :created or :bad_request
  Falls into FallbackController.

  ## Example:
    iex> #{__MODULE__}.create(
      conn, 
      %{
        name: "name",
        email: "email@mail.com",
        cep: "000000000",
        password: "0000000000000"
      }
    )
    %Plug.Conn{status: 201}

    iex> #{__MODULE__}.create(
      conn, 
      %{
        name: "name",
        email: "email@mail.com",
        cep: "000000000",
        password: "0000"
      }
    )
    %Plug.Conn{status: 400}
  """
  @spec create(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def create(conn, params) do
    with {:ok, %User{} = user} <- Create.call(params) do
      conn
      |> put_status(:created)
      |> render(:create, user: user)
    end
  end
end
