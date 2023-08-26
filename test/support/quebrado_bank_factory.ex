defmodule QuebradoBank.Factory do
  use ExMachina.Ecto, repo: QuebradoBank.Repo

  alias QuebradoBank.Users.User
  alias QuebradoBank.Accounts.Account

  def user_factory do
    %User{
      name: sequence("Rudeus Greyrat"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password_hash: sequence("00000000") |> Argon2.hash_pwd_salt(),
      cep: sequence("00000000")
    }
  end

  def account_factory do
    %Account{balance: 123}
  end
end
