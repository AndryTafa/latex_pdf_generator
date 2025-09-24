defmodule PdfGenerator.Worker do
  @moduledoc """
  A GenServer worker process for handling PDF generation from LaTeX content.

  This worker is designed to be used with a process pool (mainly poolboy) to handle
  concurrent PDF generation requests efficiently.
  """

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc """
  Initializes the worker with empty state.
  """
  def init(_) do
    {:ok, nil}
  end

  @doc """
  Handles synchronous PDF generation requests.

  ## Parameters
  - `{:generate_pdf, latex_content}` - Tuple containing the operation type and LaTeX string
  - `_from` - Caller information (unused)
  - `state` - Current GenServer state

  ## Returns
  - `{:reply, result, state}` where result is the PDF generation result
  """
  def handle_call({:generate_pdf, latex_content}, _from, state) do
    IO.puts("Worker #{inspect(self())} generating PDF")

    result = PdfGenerator.Clients.Pdf.latex_to_pdf(latex_content)

    {:reply, result, state}
  end
end
