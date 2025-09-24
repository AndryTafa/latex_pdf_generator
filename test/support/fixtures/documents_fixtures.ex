defmodule PdfGenerator.DocumentsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PdfGenerator.Documents` context.
  """

  @doc """
  Generate a master_document.
  """
  def master_document_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        document_name: "some document_name",
        latex_content: "some latex_content",
        document_id: "7488a646-e31f-11e4-aace-600308960662"
      })

    {:ok, master_document} = PdfGenerator.Documents.create_master_document(scope, attrs)
    master_document
  end
end
