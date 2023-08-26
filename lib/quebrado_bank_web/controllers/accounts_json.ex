defmodule QuebradoBankWeb.AccountsJSON do
  @moduledoc """
  Accounts Json, create json response from Accounts controller.
  """
  alias QuebradoBank.Accounts.Account

  @doc "JSON response for a created Account."
  @spec create(map()) :: map()
  def create(%{account: %Account{id: id, balance: balance, user_id: user_id}}) do
    %{message: "Account created successfully", id: id, balance: balance, user_id: user_id}
  end
end
