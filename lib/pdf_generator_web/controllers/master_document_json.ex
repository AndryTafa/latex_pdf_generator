defmodule PdfGeneratorWeb.MasterDocumentJSON do
  alias PdfGenerator.Documents.MasterDocument

  @doc """
  Renders a list of master_documents.
  """
  def index(%{master_documents: master_documents}) do
    %{data: for(master_document <- master_documents, do: data(master_document))}
  end

  @doc """
  Renders a single master_document.
  """
  def show(%{master_document: master_document}) do
    %{data: data(master_document)}
  end

  defp data(%MasterDocument{} = master_document) do
    %{
      id: master_document.id,
      document_id: master_document.document_id,
      document_name: master_document.document_name,
      latex_content: master_document.latex_content
    }
  end
end
