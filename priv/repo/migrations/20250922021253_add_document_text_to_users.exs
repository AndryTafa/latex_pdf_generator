defmodule PdfGenerator.Repo.Migrations.AddDocumentTextToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :document_text, :text
    end
  end
end
