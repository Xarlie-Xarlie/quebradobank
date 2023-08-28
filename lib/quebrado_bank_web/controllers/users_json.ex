defmodule QuebradoBankWeb.UsersJSON do
  @moduledoc """
  Users Json, create json response from Users controller.
  """
  alias QuebradoBank.Users.User

  @doc "JSON response for a created User."
  @spec create(map()) :: map()
  def create(%{user: %User{id: id, cep: cep, email: email, name: name}}) do
    %{message: "User created successfully", id: id, email: email, cep: cep, name: name}
  end

  @doc "JSON response for User."
  @spec get(map()) :: map()
  def get(%{user: %User{} = user}), do: user

  @doc "JSON response for an updated User."
  @spec update(map()) :: map()
  def update(%{user: %User{} = user}), do: %{user: user, message: "User updated successfully"}

  @doc "JSON response for a deleted User."
  @spec delete(map()) :: map()
  def delete(%{user: %User{} = user}), do: %{user: user, message: "User deleted successfully"}

  @doc "JSON response for a logged user"
  @spec login(map()) :: map()
  def login(%{token: token}), do: %{message: "Login successfully", bearer: token}
end
