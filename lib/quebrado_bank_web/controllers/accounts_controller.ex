defmodule QuebradoBankWeb.AccountsController do
  @moduledoc """
  Accounts Controller.

  Handle with create, update users.

  Returns a JSON with account's info.
  Falls into FallbackController.
  """
  use QuebradoBankWeb, :controller

  alias QuebradoBank.Accounts
  alias Accounts.Account
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
  def create(conn, params) do
    with {:ok, %Account{} = account} <- Accounts.create(params) do
      conn
      |> put_status(:created)
      |> render(:create, account: account)
    end
  end
end
