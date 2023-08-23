defmodule QuebradoBankWeb.UsersJSONTest do
  use QuebradoBankWeb.ConnCase, async: true

  import QuebradoBank.Factory

  alias QuebradoBank.Users.User
  alias QuebradoBankWeb.UsersJSON

  setup do
    params_for(:user,
      id: 123,
      name: "user name",
      email: "user@mail.com",
      cep: "12345678"
    )
    |> then(&struct(User, &1))
    |> then(&{:ok, %{user: &1}})
  end

  describe "create/1" do
    test "renders created user", %{user: user} do
      assert UsersJSON.create(%{user: user}) == %{
               message: "User created successfully",
               id: user.id,
               email: user.email,
               cep: user.cep,
               name: user.name
             }
    end
  end

  describe "get/1" do
    test "renders got user", %{user: user} do
      assert UsersJSON.get(%{user: user}) ==
               user
    end
  end

  describe "update/1" do
    test "renders updated user", %{user: user} do
      assert UsersJSON.update(%{user: user}) ==
               %{user: user, message: "User updated successfully"}
    end
  end

  describe "delete/1" do
    test "renders deleted user", %{user: user} do
      assert UsersJSON.delete(%{user: user}) ==
               %{user: user, message: "User deleted successfully"}
    end
  end
end
