defmodule PdfGenerator.DocumentsTest do
  use PdfGenerator.DataCase

  alias PdfGenerator.Documents

  describe "master_documents" do
    alias PdfGenerator.Documents.MasterDocument

    import PdfGenerator.AccountsFixtures, only: [user_scope_fixture: 0]
    import PdfGenerator.DocumentsFixtures

    @invalid_attrs %{document_id: nil, document_name: nil, latex_content: nil}

    test "list_master_documents/1 returns all scoped master_documents" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      other_master_document = master_document_fixture(other_scope)
      assert Documents.list_master_documents(scope) == [master_document]
      assert Documents.list_master_documents(other_scope) == [other_master_document]
    end

    test "get_master_document!/2 returns the master_document with given id" do
      scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      other_scope = user_scope_fixture()
      assert Documents.get_master_document!(scope, master_document.id) == master_document
      assert_raise Ecto.NoResultsError, fn -> Documents.get_master_document!(other_scope, master_document.id) end
    end

    test "create_master_document/2 with valid data creates a master_document" do
      valid_attrs = %{document_id: "7488a646-e31f-11e4-aace-600308960662", document_name: "some document_name", latex_content: "some latex_content"}
      scope = user_scope_fixture()

      assert {:ok, %MasterDocument{} = master_document} = Documents.create_master_document(scope, valid_attrs)
      assert master_document.document_id == "7488a646-e31f-11e4-aace-600308960662"
      assert master_document.document_name == "some document_name"
      assert master_document.latex_content == "some latex_content"
      assert master_document.user_id == scope.user.id
    end

    test "create_master_document/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Documents.create_master_document(scope, @invalid_attrs)
    end

    test "update_master_document/3 with valid data updates the master_document" do
      scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      update_attrs = %{document_id: "7488a646-e31f-11e4-aace-600308960668", document_name: "some updated document_name", latex_content: "some updated latex_content"}

      assert {:ok, %MasterDocument{} = master_document} = Documents.update_master_document(scope, master_document, update_attrs)
      assert master_document.document_id == "7488a646-e31f-11e4-aace-600308960668"
      assert master_document.document_name == "some updated document_name"
      assert master_document.latex_content == "some updated latex_content"
    end

    test "update_master_document/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      master_document = master_document_fixture(scope)

      assert_raise MatchError, fn ->
        Documents.update_master_document(other_scope, master_document, %{})
      end
    end

    test "update_master_document/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Documents.update_master_document(scope, master_document, @invalid_attrs)
      assert master_document == Documents.get_master_document!(scope, master_document.id)
    end

    test "delete_master_document/2 deletes the master_document" do
      scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      assert {:ok, %MasterDocument{}} = Documents.delete_master_document(scope, master_document)
      assert_raise Ecto.NoResultsError, fn -> Documents.get_master_document!(scope, master_document.id) end
    end

    test "delete_master_document/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      assert_raise MatchError, fn -> Documents.delete_master_document(other_scope, master_document) end
    end

    test "change_master_document/2 returns a master_document changeset" do
      scope = user_scope_fixture()
      master_document = master_document_fixture(scope)
      assert %Ecto.Changeset{} = Documents.change_master_document(scope, master_document)
    end
  end
end
