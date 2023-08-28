defmodule QuebradoBankWeb.UsersControllerTest do
  @moduledoc """
  Tests For Users Controller.
  Uses ExMachina for Factory.
  """
  use QuebradoBankWeb.ConnCase, async: true

  import QuebradoBank.Factory
  import Mox

  alias QuebradoBank.Repo
  alias QuebradoBank.Users.User
  alias QuebradoBank.ViaCep.ClientMock

  setup :verify_on_exit!

  describe "create/2" do
    test "successfully creates an user", %{conn: conn} do
      expect(ClientMock, :call, fn _cep -> success_cep_get() end)

      params = %{
        cep: "12345678",
        email: "test@mail.com",
        name: "test_name",
        password: "12345678"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:created)

      assert response["cep"] === "12345678"
      assert response["email"] === "test@mail.com"
      assert response["message"] === "User created successfully"
      assert response["name"] === "test_name"
    end

    test "failed to creates an user with wrong params", %{conn: conn} do
      expect(ClientMock, :call, fn _cep -> success_cep_get() end)

      params = %{
        cep: "1234",
        email: "test@mail.com",
        name: "test_name",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:bad_request)

      assert response == %{
               "errors" => %{
                 "cep" => ["should be at least 5 character(s)"],
                 "password" => ["should be at least 8 character(s)"]
               }
             }
    end

    test "failed to create an user with wrong cep", %{conn: conn} do
      expect(ClientMock, :call, fn _cep -> {:error, :not_found} end)

      params = %{
        cep: "12345678",
        email: "test@mail.com",
        name: "test_name",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:not_found)

      assert response == %{"message" => "not_found"}
    end

    test "failed to create an user with invalid cep", %{conn: conn} do
      expect(ClientMock, :call, fn _cep -> {:error, :bad_request} end)

      params = %{
        cep: "12345678",
        email: "test@mail.com",
        name: "test_name",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "bad_request"}
    end

    test "failed to create an user due to internal_server_error", %{conn: conn} do
      expect(ClientMock, :call, fn _cep -> {:error, :internal_server_error} end)

      params = %{
        cep: "12345678",
        email: "test@mail.com",
        name: "test_name",
        password: "123456"
      }

      response =
        conn
        |> post(~p"/api/users", params)
        |> json_response(:internal_server_error)

      assert response == %{"message" => "internal_server_error"}
    end
  end

  describe "show/2" do
    setup do
      user = insert(:user)

      {:ok, %{user: user}}
    end

    test "get an user", %{conn: conn, user: user} do
      response =
        conn
        |> get(~p"/api/users/#{user.id}")
        |> json_response(:ok)

      assert response["cep"] == user.cep
      assert response["name"] == user.name
      assert response["email"] == user.email
    end

    test "fails to get a user", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/#{0}")
        |> json_response(:not_found)

      assert response == %{"message" => "Not Found"}
    end

    test "returns id not valid when pass string as id", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/abc")
        |> json_response(:bad_request)

      assert response == %{"message" => "Not valid id"}
    end

    test "returns id not valid when pass a wrong id", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/a1b2c3")
        |> json_response(:bad_request)

      assert response == %{"message" => "Not valid id"}
    end
  end

  describe "udpate/3" do
    setup do
      user = insert(:user)

      {:ok, %{user: user}}
    end

    test "updates user's name", %{conn: conn, user: user} do
      new_name = "new_name"
      params = %{name: new_name}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:ok)

      assert response == %{
               "message" => "User updated successfully",
               "user" => %{
                 "name" => new_name,
                 "cep" => user.cep,
                 "email" => user.email
               }
             }
    end

    test "updates user's email", %{conn: conn, user: user} do
      new_email = "new_email@mail.com"
      params = %{email: new_email}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:ok)

      assert response == %{
               "message" => "User updated successfully",
               "user" => %{
                 "name" => user.name,
                 "cep" => user.cep,
                 "email" => new_email
               }
             }
    end

    test "updates user's cep", %{conn: conn, user: user} do
      expect(ClientMock, :call, fn _cep -> success_cep_get() end)
      new_cep = "9876564321"
      params = %{cep: new_cep}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:ok)

      assert response == %{
               "message" => "User updated successfully",
               "user" => %{
                 "name" => user.name,
                 "cep" => new_cep,
                 "email" => user.email
               }
             }
    end

    test "updates to a not found cep", %{conn: conn, user: user} do
      expect(ClientMock, :call, fn _cep -> {:error, :not_found} end)
      new_cep = "9876564321"
      params = %{cep: new_cep}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:not_found)

      assert response == %{"message" => "not_found"}
    end

    test "updates to a invalid cep", %{conn: conn, user: user} do
      expect(ClientMock, :call, fn _cep -> {:error, :bad_request} end)
      new_cep = "9876564321"
      params = %{cep: new_cep}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:bad_request)

      assert response == %{"message" => "bad_request"}
    end

    test "tries to update but receive server error from viacep", %{conn: conn, user: user} do
      expect(ClientMock, :call, fn _cep -> {:error, :internal_server_error} end)
      new_cep = "9876564321"
      params = %{cep: new_cep}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:internal_server_error)

      assert response == %{"message" => "internal_server_error"}
    end

    test "updates user's password", %{conn: conn, user: user} do
      new_password = "9876564321"
      params = %{password: new_password}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:ok)

      assert response == %{
               "message" => "User updated successfully",
               "user" => %{
                 "name" => user.name,
                 "cep" => user.cep,
                 "email" => user.email
               }
             }

      %User{password_hash: new_password_hash} = Repo.get(User, user.id)

      refute new_password_hash == user.password_hash
    end

    test "updates to invalid params", %{conn: conn, user: user} do
      params = %{password: "1234"}

      response =
        conn
        |> put(~p"/api/users/#{user.id}", params)
        |> json_response(:bad_request)

      assert response == %{"errors" => %{"password" => ["should be at least 8 character(s)"]}}
    end
  end

  describe "delete/2" do
    setup do
      user = insert(:user)

      {:ok, %{user: user}}
    end

    test "deletes a user", %{conn: conn, user: user} do
      conn
      |> delete(~p"/api/users/#{user.id}")
      |> json_response(:ok)

      assert nil == Repo.get(User, user.id)
    end

    test "return not found for user with inexistent id", %{conn: conn} do
      response =
        conn
        |> delete(~p"/api/users/0")
        |> json_response(:not_found)

      assert response == %{"message" => "Not Found"}
    end

    test "return not valid id for a wrong id", %{conn: conn} do
      response =
        conn
        |> delete(~p"/api/users/a0")
        |> json_response(:bad_request)

      assert response == %{"message" => "Not valid id"}
    end
  end

  describe "login/2" do
    setup do
      password = "1234"
      user = insert(:user, password: password, password_hash: Argon2.hash_pwd_salt(password))

      {:ok, %{user: user, password: password}}
    end

    test "logins an user", %{conn: conn, user: user, password: password} do
      params = %{email: user.email, password: password}

      response =
        conn
        |> post(~p"/api/users/login", params)
        |> json_response(:ok)

      assert response == %{"message" => "Login successfully", "bearer" => response["bearer"]}
      refute response["bearer"] === ""
    end

    test "fails login an user with wrong password", %{conn: conn, user: user} do
      params = %{email: user.email, password: "4321"}

      response =
        conn
        |> post(~p"/api/users/login", params)
        |> json_response(:unauthorized)

      assert response == %{"message" => "unauthorized"}
    end

    test "fails login an inexistent user", %{conn: conn} do
      params = %{email: "mymail@mail.com", password: "4321"}

      response =
        conn
        |> post(~p"/api/users/login", params)
        |> json_response(:not_found)

      assert response == %{"message" => "not_found"}
    end

    test "with wrong params", %{conn: conn} do
      conn
      |> post(~p"/api/users/login", %{})
      |> json_response(:unauthorized)
    end
  end

  defp success_cep_get do
    {:ok, %Tesla.Env{status: 200, body: ~s({"cep": "65700-000"})}}
  end
end
