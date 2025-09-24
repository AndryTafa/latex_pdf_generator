defmodule PdfGenerator.Documents.MasterDocument do
  use Ecto.Schema
  import Ecto.Changeset

  schema "master_documents" do
    field :document_id, Ecto.UUID
    field :document_name, :string
    field :latex_content, :string
    belongs_to :user, PdfGenerator.Accounts.User 
    
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(master_document, attrs, user_scope) do
    master_document
    |> cast(attrs, [:document_id, :document_name, :latex_content])
    |> validate_required([:document_id, :latex_content])
    |> put_change(:user_id, user_scope.user.id)
  end
end
