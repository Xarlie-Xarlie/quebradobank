defmodule QuebradoBankWeb.UsersController do
  @moduledoc """
  Users Controller.

  Handle with create, update, read, delete users.

  Returns a JSON with user's info.
  Falls into FallbackController.
  """
  use QuebradoBankWeb, :controller

  alias QuebradoBankWeb.FallbackController
  alias QuebradoBank.Users
  alias QuebradoBank.Users.User
  alias QuebradoBankWeb.Token

  action_fallback(FallbackController)

  @doc """
  Create a new user.

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
  Get an user.

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

  @doc """
  Update an user.

  ## Parameters:
    `params`: params to update user, also need `id` key.

  ## Examples:
    iex> #{__MODULE__}.update(
      conn,
      %{"id" => 1, "name" => "new_name"}
    )
    Plug.Conn{status: 200}

    iex> #{__MODULE__}.update(
      conn,
      %{"id" => 100, "cep" => "1234"}
    )
    Plug.Conn{status: 400}
  """
  @spec update(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def update(conn, params) do
    with {:ok, %User{} = user} <- Users.update(params) do
      conn
      |> put_status(:ok)
      |> render(:update, user: user)
    end
  end

  @doc """
  Delete an user.

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
  @spec delete(Plug.Conn.t(), map()) :: Plug.Conn.t()
  def delete(conn, %{"id" => id}) do
    with {:ok, %User{} = user} <- Users.delete(id) do
      conn
      |> put_status(:ok)
      |> render(:delete, user: user)
    end
  end

  @spec login(Plug.Conn.t(), map()) :: Plug.Conn.t() | {:error, any()}
  def login(conn, params) do
    with {:ok, %User{} = user} <- Users.login(params),
         token <- Token.sign(user) do
      conn
      |> put_status(:ok)
      |> render(:login, %{token: token})
    end
  end
end
