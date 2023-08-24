defmodule QuebradoBankWeb.FallbackControllerTest do
  use QuebradoBankWeb.ConnCase, async: true

  import Mox

  alias QuebradoBank.ViaCep.ClientMock

  setup :verify_on_exit!

  describe "fallback controller call/2" do
    test "take the callback from users with changeset", %{conn: conn} do
      expect(ClientMock, :call, fn cep ->
        {:ok, %Tesla.Env{status: 200, body: ~s({"cep": #{cep})}}
      end)

      response =
        conn
        |> post(~p"/api/users", %{"cep" => "00000000"})
        |> json_response(:bad_request)

      assert response ==
               %{
                 "errors" => %{
                   "email" => ["can't be blank"],
                   "name" => ["can't be blank"],
                   "password" => ["can't be blank"]
                 }
               }
    end

    test "take the callback from user with message", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/0")
        |> json_response(:not_found)

      assert response == %{"message" => "Not Found"}
    end

    test "take the callback from user with wrong id", %{conn: conn} do
      response =
        conn
        |> get(~p"/api/users/abc123")
        |> json_response(:not_found)

      assert response == %{"message" => "Not valid id"}
    end
  end
end
