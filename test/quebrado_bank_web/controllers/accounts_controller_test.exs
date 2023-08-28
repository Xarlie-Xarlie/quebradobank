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

      response =
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:not_found)

      assert response == %{"message" => "User not found"}
    end

    test "raise an error for an empty user_id", %{conn: conn} do
      params = %{}

      response =
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "missing user_id param"}
    end

    test "can't create two accounts for the same user", %{conn: conn, user: user} do
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

      response =
        conn
        |> post(~p"/api/accounts", params)
        |> json_response(:bad_request)

      assert response == %{"errors" => %{"user_id" => ["has already been taken"]}}
    end
  end

  describe "transaction/2" do
    setup do
      user_1 =
        insert(:user,
          name: "user one",
          email: "userone@mail.com",
          cep: "12345678"
        )

      user_2 =
        insert(:user,
          name: "user two",
          email: "usertwo@mail.com",
          cep: "12345678"
        )

      account_1 = insert(:account, user_id: user_1.id, balance: 10000)
      account_2 = insert(:account, user_id: user_2.id, balance: 5000)

      {:ok, %{account_1: account_1, account_2: account_2}}
    end

    test "transfer values between two accounts", %{
      conn: conn,
      account_1: account_1,
      account_2: account_2
    } do
      value_to_transfer = 100

      params = %{
        origin_account: account_1.id,
        destination_account: account_2.id,
        value: value_to_transfer
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:ok)

      assert response == %{"message" => "transaction finished successfully"}

      updated_account_1 = Repo.get(Account, account_1.id)
      updated_account_2 = Repo.get(Account, account_2.id)

      refute is_nil(updated_account_1)
      refute is_nil(updated_account_2)

      refute updated_account_1.balance === account_1.balance
      assert updated_account_1.balance === Decimal.sub(account_1.balance, value_to_transfer)

      refute updated_account_2.balance === account_2.balance
      assert updated_account_2.balance === Decimal.add(account_2.balance, value_to_transfer)
    end

    test "transfer a value not available in account", %{
      conn: conn,
      account_1: account_1,
      account_2: account_2
    } do
      value_to_transfer = 100_000

      params = %{
        origin_account: account_1.id,
        destination_account: account_2.id,
        value: value_to_transfer
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:bad_request)

      assert response == %{"errors" => %{"balance" => ["is invalid"]}}

      updated_account_1 = Repo.get(Account, account_1.id)
      updated_account_2 = Repo.get(Account, account_2.id)

      refute is_nil(updated_account_1)
      refute is_nil(updated_account_2)

      assert updated_account_1.balance === account_1.balance
      assert updated_account_2.balance === account_2.balance
    end

    test "Do not transfer to the same account", %{conn: conn, account_1: account_1} do
      value_to_transfer = 100

      params = %{
        origin_account: account_1.id,
        destination_account: account_1.id,
        value: value_to_transfer
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "you can't transfer to the same account!"}
    end

    test "Do not execute transaction for negative values", %{
      conn: conn,
      account_1: account_1,
      account_2: account_2
    } do
      value_to_transfer = -100

      params = %{
        origin_account: account_1.id,
        destination_account: account_2.id,
        value: value_to_transfer
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "value is not valid"}
    end

    test "Do not execute transaction for invalid values", %{
      conn: conn,
      account_1: account_1,
      account_2: account_2
    } do
      value_to_transfer = "abc"

      params = %{
        origin_account: account_1.id,
        destination_account: account_2.id,
        value: value_to_transfer
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "value is not valid"}
    end

    test "Do not execute transaction when account does not exists", %{
      conn: conn,
      account_1: account_1,
      account_2: account_2
    } do
      params = %{
        origin_account: account_1.id,
        destination_account: -1,
        value: 100
      }

      response =
        conn
        |> post(~p"/api/accounts/transaction", params)
        |> json_response(:not_found)

      assert response == %{"message" => "destination account not found"}

      params_2 = %{
        origin_account: -1,
        destination_account: account_2.id,
        value: 100
      }

      response_2 =
        conn
        |> post(~p"/api/accounts/transaction", params_2)
        |> json_response(:not_found)

      assert response_2 == %{"message" => "origin account not found"}
    end

    test "not pass params to transaction", %{conn: conn} do
      response =
        conn
        |> post(~p"/api/accounts/transaction", %{})
        |> json_response(:unprocessable_entity)

      assert response == %{"message" => "unprocessable_entity"}
    end
  end
end
