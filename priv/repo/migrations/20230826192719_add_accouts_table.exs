defmodule QuebradoBank.Repo.Migrations.AddAccoutsTable do
  use Ecto.Migration

  def up do
    create table(:accounts) do
      add(:balance, :decimal, default: 0)
      add(:user_id, references(:users))

      timestamps()
    end

    create constraint(:accounts, :balance_must_be_positive, check: "balance >= 0")
    create unique_index(:accounts, [:user_id])
  end

  def down do
    drop constraint(:accounts, :balance_must_be_positive)
    drop unique_index(:accounts, [:user_id])

    drop(table(:accounts))
  end
end
