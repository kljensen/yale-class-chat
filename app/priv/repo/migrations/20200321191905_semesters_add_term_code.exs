defmodule App.Repo.Migrations.SemestersAddTermCode do
  use Ecto.Migration

  def change do
    alter table(:semesters) do
      add :term_code, :string, null: false, default: "202001"
    end
  end
end
