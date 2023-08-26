defmodule QuebradoBankWeb.AccountsJSONTest do
  use QuebradoBankWeb.ConnCase, async: true

  import QuebradoBank.Factory

  alias QuebradoBankWeb.AccountsJSON

  setup do
    user =
      insert(:user,
        name: "user name",
        email: "user@mail.com",
        cep: "12345678"
      )

    account = insert(:account, user_id: user.id)

    {:ok, %{account: account}}
  end

  describe "create/1" do
    test "renders created user", %{account: account} do
      assert AccountsJSON.create(%{account: account}) == %{
               message: "Account created successfully",
               id: account.id,
               balance: account.balance,
               user_id: account.user_id
             }
    end
  end
end
