defmodule PdfGeneratorWeb.Dashboard.Index do
  use PdfGeneratorWeb, :live_view

  @max_document_context_length 12_000

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="p-4">
        <h1 class="text-2xl font-bold mb-4">Dashboard</h1>

        <.document_context_form form={@form} loading={@document_loading} />

        <%= if @document_loading do %>
          <div class="mt-4 p-4 bg-blue-50 border border-blue-200 rounded">
          <p class="text-blue-800">
          <span class="animate-spin inline-block mr-2">⟳</span>
          Generating your document...
          </p>
          </div>
          <% end %>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign_user_data(socket.assigns.current_scope.user)
      |> assign_initial_form()
      |> assign(:document_context, "")
      |> assign(:document_loading, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("update_document_context", %{"document_form" => params}, socket) do
    document_context = get_document_context(params)
    truncated_context = truncate_document_context(document_context)

    socket =
      socket
      |> assign(:document_context, truncated_context)
      |> assign(:form, build_form(truncated_context))
      |> assign(:document_loading, true)

    # TODO: ideally also put this in a queue
    send(self(), {:generate_document, truncated_context})

    {:noreply, socket}
  end

  @impl true
  def handle_info({:generate_document, document_context}, socket) do
    case generate_document_pdf_content(document_context) do
      {:ok, pdf_binary} ->
        pdf_base64 = Base.encode64(pdf_binary)

        socket =
          socket
          |> assign(:document_loading, false)
          |> push_event("download_pdf", %{
            data: pdf_base64,
            filename: "document_#{Date.utc_today()}.pdf"
          })
          |> put_flash(:info, "Document generated successfully!")

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> assign(:document_loading, false)
          |> put_flash(:error, "Failed to generate document: #{format_error(reason)}")

        {:noreply, socket}
    end
  end

  defp generate_document_pdf_content(document_context) do
    start_time = System.monotonic_time(:millisecond)

    result = with {:ok, response} <- PdfGenerator.Clients.OpenRouter.latex_completion(
           document_context
         ),
         generated_latex <- extract_latex_from_response(response),
         {:ok, pdf_binary} <- PdfGenerator.Clients.Pdf.generate(generated_latex) do
      {:ok, pdf_binary}
    else
      {:error, reason} -> {:error, reason}
      error -> {:error, error}
    end

    duration = System.monotonic_time(:millisecond) - start_time
    IO.puts("Document generation took #{duration}ms")

    result
  end

  defp extract_latex_from_response(%Req.Response{body: body}) do
    body["choices"]
    |> List.first()
    |> get_in(["message", "content"])
  end

  defp format_error(reason) when is_binary(reason), do: reason
  defp format_error(reason), do: inspect(reason)

  defp assign_user_data(socket, current_user) do
    socket
    |> assign(:current_user, current_user)
    |> assign(:user_document_text, "")
  end

  defp assign_initial_form(socket) do
    assign(socket, :form, build_form(""))
  end

  defp get_document_context(%{"document_context" => document_context}), do: document_context
  defp get_document_context(_), do: ""

  defp truncate_document_context(context) do
    String.slice(context, 0, @max_document_context_length)
  end

  defp build_form(document_context) do
    to_form(%{"document_context" => document_context}, as: :document_form)
  end

  defp document_context_form(assigns) do
    ~H"""
    <div class="mb-6" phx-hook="PDFDownloader" id="pdf_downloader">
      <.form for={@form} phx-submit="update_document_context">
        <div class="mb-4">
          <label for="document_context" class="block text-sm font-medium mb-2">
            Document Context
          </label>
          <.input
            field={@form[:document_context]}
            type="textarea"
            placeholder="Paste the document context here..."
            rows="8"
            class="w-full"
            maxlength="12000"
          />
        </div>
        <.button type="submit" disabled={@loading}>
          <%= if @loading do %>
            <span class="animate-spin inline-block mr-2">⟳</span>
            Generating Document...
            <% else %>
            Generate Document
            <% end %>
        </.button>
      </.form>
    </div>
    """
  end
end
