defmodule PdfGenerator.Documents do
  @moduledoc """
  The Documents context.
  """

  import Ecto.Query, warn: false
  alias PdfGenerator.Repo

  alias PdfGenerator.Documents.MasterDocument
  alias PdfGenerator.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any master_document changes.

  The broadcasted messages match the pattern:

    * {:created, %MasterDocument{}}
    * {:updated, %MasterDocument{}}
    * {:deleted, %MasterDocument{}}

  """
  def subscribe_master_documents(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(PdfGenerator.PubSub, "user:#{key}:master_documents")
  end

  defp broadcast_master_document(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(PdfGenerator.PubSub, "user:#{key}:master_documents", message)
  end

  @doc """
  Returns the list of master_documents.

  ## Examples

      iex> list_master_documents(scope)
      [%MasterDocument{}, ...]

  """
  def list_master_documents(%Scope{} = scope) do
    Repo.all_by(MasterDocument, user_id: scope.user.id)
  end

  @doc """
  Gets a single master_document.

  Raises `Ecto.NoResultsError` if the Master document does not exist.

  ## Examples

      iex> get_master_document!(scope, 123)
      %MasterDocument{}

      iex> get_master_document!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_master_document!(%Scope{} = scope, id) do
    Repo.get_by!(MasterDocument, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a master_document.

  ## Examples

      iex> create_master_document(scope, %{field: value})
      {:ok, %MasterDocument{}}

      iex> create_master_document(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_master_document(%Scope{} = scope, attrs) do
    with {:ok, master_document = %MasterDocument{}} <-
           %MasterDocument{}
           |> MasterDocument.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_master_document(scope, {:created, master_document})
      {:ok, master_document}
    end
  end

  @doc """
  Updates a master_document.

  ## Examples

      iex> update_master_document(scope, master_document, %{field: new_value})
      {:ok, %MasterDocument{}}

      iex> update_master_document(scope, master_document, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_master_document(%Scope{} = scope, %MasterDocument{} = master_document, attrs) do
    true = master_document.user_id == scope.user.id

    with {:ok, master_document = %MasterDocument{}} <-
           master_document
           |> MasterDocument.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_master_document(scope, {:updated, master_document})
      {:ok, master_document}
    end
  end

  @doc """
  Deletes a master_document.

  ## Examples

      iex> delete_master_document(scope, master_document)
      {:ok, %MasterDocument{}}

      iex> delete_master_document(scope, master_document)
      {:error, %Ecto.Changeset{}}

  """
  def delete_master_document(%Scope{} = scope, %MasterDocument{} = master_document) do
    true = master_document.user_id == scope.user.id

    with {:ok, master_document = %MasterDocument{}} <-
           Repo.delete(master_document) do
      broadcast_master_document(scope, {:deleted, master_document})
      {:ok, master_document}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking master_document changes.

  ## Examples

      iex> change_master_document(scope, master_document)
      %Ecto.Changeset{data: %MasterDocument{}}

  """
  def change_master_document(%Scope{} = scope, %MasterDocument{} = master_document, attrs \\ %{}) do
    true = master_document.user_id == scope.user.id

    MasterDocument.changeset(master_document, attrs, scope)
  end
end
