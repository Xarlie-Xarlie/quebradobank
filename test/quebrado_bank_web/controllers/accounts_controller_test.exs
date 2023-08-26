defmodule QuebradoBankWeb.AccountsControllerTest do
  @moduledoc """
  Tests for Accounts Controller.
  Uses ExMachina for factory.
  """
  use QuebradoBankWeb.ConnCase, async: true

  import QuebradoBank.Factory

  alias QuebradoBank.Repo
  alias QuebradoBank.Accounts.Account

  describe "create/2" do
    setup do
      user =
        insert(:user,
          name: "user name",
          email: "user@mail.com",
          cep: "12345678"
        )

      {:ok, %{user: user}}
    end

    test "successfully creates an account", %{conn: conn, user: user} do
      params = %{user_id: user.id}

      response =
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:created)

      assert response == %{
               "message" => "Account created successfully",
               "id" => response["id"],
               "user_id" => user.id,
               "balance" => "0"
             }

      account = Repo.get(Account, response["id"])

      refute is_nil(account)

      assert account.balance === Decimal.new(0)
    end

    test "only creates a new account with balance 0", %{conn: conn, user: user} do
      params = %{user_id: user.id, balance: 12345}

      response =
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:created)

      assert response == %{
               "message" => "Account created successfully",
               "id" => response["id"],
               "user_id" => user.id,
               "balance" => "0"
             }

      account = Repo.get(Account, response["id"])

      refute is_nil(account)

      assert account.balance === Decimal.new(0)
    end

    test "raise an error for an inexistent user", %{conn: conn} do
      params = %{user_id: -1, balance: 12345}

      assert_raise Ecto.ConstraintError, fn ->
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:bad_request)
      end
    end
  end
end
