defmodule QuebradoBankWeb.UsersController do
  @moduledoc """
  Users Controller.

  Handle with create, update, read, delete users.
  """
  use QuebradoBankWeb, :controller

  alias QuebradoBankWeb.FallbackController
  alias QuebradoBank.Users
  alias QuebradoBank.Users.User

  action_fallback(FallbackController)

  @doc """
  Create a new user.

  Returns JSON response with :created or :bad_request
  Falls into FallbackController.

  ## Parameters:
    - `params`: params for a new user.

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
    with {:ok, %User{} = user} <- Users.create(params) do
      conn
      |> put_status(:created)
      |> render(:create, user: user)
    end
  end

  @doc """
  Get an user by id.

  Returns a JSON with user's info.
  Falls into FallbackController.

  ## Parameters:
    `id`: id of an User.

  ## Examples:
    iex> #{__MODULE__}.show(
      conn,
      %{"id" => 1}
    )
    Plug.Conn{status: 200}

    iex> #{__MODULE__}.show(
      conn,
      %{"id" => 100}
    )
    Plug.Conn{status: 400}
  """
  @spec show(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def show(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.get(id) do
      conn
      |> put_status(:ok)
      |> render(:get, user: user)
    end
  end

  def update(conn, params) do
    with {:ok, %User{} = user} <- Users.update(params) do
      conn
      |> put_status(:ok)
      |> render(:update, user: user)
    end
  end
end
