defmodule QuebradoBankWeb.UsersJSON do
  @moduledoc """
  Users Json, create json response from Users controller.
  """
  alias QuebradoBank.Users.User

  def create(%{user: %User{id: id, cep: cep, email: email, name: name}}) do
    %{message: "User created successfully", id: id, email: email, cep: cep, name: name}
  end
end
