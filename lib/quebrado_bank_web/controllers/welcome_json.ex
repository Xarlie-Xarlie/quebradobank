defmodule QuebradoBankWeb.WelcomeJSON do
  @moduledoc """
  Users Json, create json response from Users controller.
  """

  @doc "Welcome message"
  @spec welcome(any()) :: map()
  def welcome(_) do
    %{
      message: "Welcome to QuebradoBank Api, https://github.com/Xarlie-Xarlie/quebradobank\n
       This is a simple web api written in Elixir/Phoenix"
    }
  end
end
