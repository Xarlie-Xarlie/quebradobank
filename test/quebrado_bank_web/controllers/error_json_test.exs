defmodule QuebradoBankWeb.ErrorJSONTest do
  use QuebradoBankWeb.ConnCase, async: true

  alias QuebradoBank.Users.User

  test "renders 404" do
    assert QuebradoBankWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert QuebradoBankWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end

  test "render 400 for changeset errors" do
    assert QuebradoBankWeb.ErrorJSON.error(%{changeset: User.changeset(%{})}) ==
             %{
               errors: %{
                 cep: ["can't be blank"],
                 email: ["can't be blank"],
                 name: ["can't be blank"],
                 password: ["can't be blank"]
               }
             }
  end

  test "render 400 for error messages" do
    assert QuebradoBankWeb.ErrorJSON.error(%{error: "Not found"}) ==
             %{message: "Not found"}

    assert QuebradoBankWeb.ErrorJSON.error(%{error: "Not valid id"}) ==
             %{message: "Not valid id"}
  end
end
