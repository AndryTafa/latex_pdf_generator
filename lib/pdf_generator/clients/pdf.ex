defmodule PdfGenerator.Clients.Pdf do
  @moduledoc """
  Client for PDF generation using pooled worker processes.
  Provides a simple interface for generating PDFs from LaTeX content via poolboy.
  """
  
  @doc """
  Generates a PDF from LaTeX content using a pooled worker.
  Borrows a worker from the pool, processes the LaTeX content, and returns
  the result. The worker is automatically returned after completion.
  ## Parameters
  - `latex_content` - String containing valid LaTeX markup
  ## Returns
  - Result from `PdfGenerator.Clients.Pdf.latex_to_pdf/1`
  ## Timeouts
  - Worker processing: 30 seconds
  - Queue + processing: 45 seconds total
  ## Examples
  iex> latex = "\\documentclass{article}\\begin{document}Hello\\end{document}"
  iex> PdfGenerator.Clients.Pdf.generate(latex)
  {:ok, pdf_binary}
  """
  def generate(latex_content) do
    :poolboy.transaction(:worker, fn pid ->
      GenServer.call(pid, {:generate_pdf, latex_content}, :timer.seconds(30))
    end, :timer.seconds(45))
  end

  @tmp_folder ".tmp"
  
  @doc """
  Converts LaTeX content to PDF binary using pdflatex.
  Creates temporary files, runs pdflatex, and cleans up automatically.
  """
  def latex_to_pdf(latex_string, options \\ []) when is_list(options) do
    unless File.dir?(@tmp_folder), do: File.mkdir(@tmp_folder)
    # FIX: error on when using API endpoint
    
    # Create temp files
    filename = random_filename()
    tex_file = Path.join(@tmp_folder, "#{filename}.tex")
    output_dir = @tmp_folder
    
    File.write(tex_file, latex_string)
    result =
      case System.cmd("pdflatex", [
        "-output-directory=#{output_dir}",
        "-interaction=nonstopmode",
        tex_file
      ] ++ options) do
        {_output, 0} -> 
          pdf_file = Path.join(@tmp_folder, "#{filename}.pdf")
          pdf_content = File.read!(pdf_file)
          {:ok, pdf_content}
        {_error, exit_code} -> 
          {:error, {exit_code}}
      end
    # Cleanup
    cleanup_files(filename)
    result
  end
  
  defp random_filename do
    Enum.join([random_string(), "-", timestamp()])
  end
  
  defp random_string(length \\ 36) do
    length
    |> :crypto.strong_rand_bytes()
    |> Base.url_encode64()
    |> String.slice(0, length)
    |> String.downcase()
  end
  
  defp timestamp do
    :os.system_time(:seconds)
  end
  
  defp cleanup_files(filename) do
    extensions = [".tex", ".pdf", ".aux", ".log", ".out"]
    
    Enum.each(extensions, fn ext ->
      file = Path.join(@tmp_folder, "#{filename}#{ext}")
      if File.exists?(file), do: File.rm(file)
    end)
  end
end
