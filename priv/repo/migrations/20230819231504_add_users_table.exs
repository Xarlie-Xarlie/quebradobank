defmodule QuebradoBank.Repo.Migrations.AddUsersTable do
  use Ecto.Migration

  def up do
    create table(:users) do
      add(:name, :string, null: false)
      add(:password_hash, :string)
      add(:email, :string, null: false)
      add(:cep, :string)

      timestamps()
    end
  end

  def down do
    drop table(:users)
  end
end
