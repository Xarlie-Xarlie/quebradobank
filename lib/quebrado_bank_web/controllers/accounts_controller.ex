defmodule QuebradoBankWeb.AccountsController do
  @moduledoc """
  Accounts Controller.

  Handle with create, update users.

  Returns a JSON with account's info.
  Falls into FallbackController.
  """
  use QuebradoBankWeb, :controller

  alias Plug.Conn
  alias QuebradoBank.Accounts
  alias QuebradoBank.Accounts.Account
  alias QuebradoBankWeb.FallbackController

  action_fallback FallbackController

  @doc """
  Create a new account.

  ## Parameters:
    - `params`: params for a new account.

  ## Example:
    iex> #{__MODULE__}.create(conn, %{user_id: 1})
    %Plug.Conn{status: 201}

    iex> #{__MODULE__}.create(conn, %{})
    %Plug.Conn{status: 400}
  """
  @spec create(Conn.t(), map()) :: Conn.t()
  def create(conn, params) do
    with {:ok, %Account{} = account} <- Accounts.create(params) do
      conn
      |> put_status(:created)
      |> render(:create, account: account)
    end
  end

  @doc """
  Perform a transaction between two accounts.

  ## Parameters:
    - `params`: map with origin, destination accounts and value.

  ## Examples:
  iex> #{__MODULE__}.transaction(
    %{
      origin_account: 1,
      destination_account: 2,
      value: 100
    }
  )
  %Plug.Conn{status: :ok}

  iex> #{__MODULE__}.transaction(
    %{
      destination_account: 2,
      value: 100
    }
  )
  %Plug.Conn{status: :unprocessable_entity}
  """
  @spec transaction(Conn.t(), map()) :: Conn.t()
  def transaction(conn, params) do
    with {:ok, _transaction} <- Accounts.transaction(params) do
      conn
      |> put_status(:ok)
      |> render(:transaction, message: "transaction finished successfully")
    end
  end
end
