defmodule PdfGenerator.Repo.Migrations.CreateMasterDocuments do
  use Ecto.Migration

  def change do
    create table(:master_documents) do
      add :user_id, references(:users, on_delete: :nothing)
      add :document_id, :uuid
      add :document_name, :string
      add :latex_content, :text

      timestamps(type: :utc_datetime)
    end

    create index(:master_documents, [:user_id])
  end
end
