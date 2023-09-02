defmodule QuebradoBankWeb.WelcomeJSON do
  @moduledoc """
  Users Json, create json response from Users controller.
  """

  @doc "Welcome message"
  @spec welcome(any()) :: map()
  def welcome(_) do
    %{message: "Welcome to QuebradoBank, https://github.com/Xarlie-Xarlie/quebradobank"}
  end
end
