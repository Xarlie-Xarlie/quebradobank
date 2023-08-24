Mox.defmock(QuebradoBank.ViaCep.ClientMock, for: QuebradoBank.ViaCep.Behaviour)
Application.put_env(:quebrado_bank, :via_cep, QuebradoBank.ViaCep.ClientMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(QuebradoBank.Repo, :manual)
