defmodule QuebradoBankWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use QuebradoBankWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint QuebradoBankWeb.Endpoint

      use QuebradoBankWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import QuebradoBankWeb.ConnCase
    end
  end

  setup tags do
    QuebradoBank.DataCase.setup_sandbox(tags)

    fake_user = QuebradoBank.Factory.insert(:user)

    {:ok,
     conn:
       Phoenix.ConnTest.build_conn()
       |> Plug.Conn.put_req_header(
         "authorization",
         "Bearer " <> QuebradoBankWeb.Token.sign(fake_user)
       )}
  end
end
