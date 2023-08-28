defmodule QuebradoBankWeb.Token do
  @moduledoc """
  Create a new token for an user.
  """

  alias Phoenix.Token
  alias QuebradoBankWeb.Endpoint
  alias QuebradoBank.Users.User

  @sign_salt "quebrado"

  @doc """
  Generates a new token.
  """
  @spec sign(User.t()) :: binary()
  def sign(%User{id: user_id}), do: Token.sign(Endpoint, @sign_salt, %{user_id: user_id})

  @doc """
  Verify if a token is valid/invalid/expired.
  """
  @spec verify(binary()) :: {:ok, map()} | {:error, :expired | :invalid | :missing}
  def verify(token), do: Token.verify(Endpoint, @sign_salt, token)
end
