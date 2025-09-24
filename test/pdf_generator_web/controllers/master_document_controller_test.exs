defmodule PdfGeneratorWeb.MasterDocumentControllerTest do
  use PdfGeneratorWeb.ConnCase

  import PdfGenerator.DocumentsFixtures
  alias PdfGenerator.Documents.MasterDocument

  @create_attrs %{
    document_id: "7488a646-e31f-11e4-aace-600308960662",
    document_name: "some document_name",
    latex_content: "some latex_content"
  }
  @update_attrs %{
    document_id: "7488a646-e31f-11e4-aace-600308960668",
    document_name: "some updated document_name",
    latex_content: "some updated latex_content"
  }
  @invalid_attrs %{document_id: nil, document_name: nil, latex_content: nil}

  setup :register_and_log_in_user

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all master_documents", %{conn: conn} do
      conn = get(conn, ~p"/api/master_documents")
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create master_document" do
    test "renders master_document when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/master_documents", master_document: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/master_documents/#{id}")

      assert %{
               "id" => ^id,
               "document_name" => "some document_name",
               "latex_content" => "some latex_content",
               "document_id" => "7488a646-e31f-11e4-aace-600308960662"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/master_documents", master_document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update master_document" do
    setup [:create_master_document]

    test "renders master_document when data is valid", %{conn: conn, master_document: %MasterDocument{id: id} = master_document} do
      conn = put(conn, ~p"/api/master_documents/#{master_document}", master_document: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/master_documents/#{id}")

      assert %{
               "id" => ^id,
               "document_name" => "some updated document_name",
               "latex_content" => "some updated latex_content",
               "document_id" => "7488a646-e31f-11e4-aace-600308960668"
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, master_document: master_document} do
      conn = put(conn, ~p"/api/master_documents/#{master_document}", master_document: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete master_document" do
    setup [:create_master_document]

    test "deletes chosen master_document", %{conn: conn, master_document: master_document} do
      conn = delete(conn, ~p"/api/master_documents/#{master_document}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/master_documents/#{master_document}")
      end
    end
  end

  defp create_master_document(%{scope: scope}) do
    master_document = master_document_fixture(scope)

    %{master_document: master_document}
  end
end
