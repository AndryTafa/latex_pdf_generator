defmodule PdfGenerator.Clients.OpenRouter do
  @moduledoc """
  Client for OpenRouter API
  """

  def latex_completion(user_instructions, model \\ "openai/gpt-5-mini") do
    messages = [
      %{
        role: "system",
        content: build_system_prompt(user_instructions)
      }
    ]

    chat_completion(messages, model) |> IO.inspect
  end

  defp build_system_prompt(user_instructions) do
    prompt = """
      You are a LaTeX document generator. Your sole purpose is to generate LaTeX code.
      You will be given one input which will be the user instructions
      Return ONLY LaTeX code. No explanations, no markdown, no conversational text. Just pure LaTeX.
      <rules>
      Do not make LaTeX syntax mistakes.
      DO NOT wrap the output in markdown code blocks (```latex or ```).
      DO NOT add any prefacing text like "Here's your LaTeX:" or explanatory comments.
      WRONG: ```latex\\documentclass[10pt]{article}...```
      CORRECT: \\documentclass[10pt]{article}...
      The response must start immediately with \\documentclass and end with \\end{document}.
      Your entire response should be compilable LaTeX code that can be directly saved as a .tex file.
      </rules>
      <user-instructions>
      #{user_instructions}
      </user-instructions>
      Generate the LaTeX document.
      """
    prompt
  end

  defp chat_completion(messages, model) do
    openrouter_api_key = System.get_env("OPENROUTER_API_KEY")

    unless openrouter_api_key do
      raise "OPENROUTER_API_KEY environment variable not set"
    end

    req = Req.new(
      base_url: "https://openrouter.ai/api/v1",
      headers: [
        {"Authorization", "Bearer #{openrouter_api_key}"},
        {"Content-Type", "application/json"}
      ]
    )

    chat_body = %{
      model: model,
      messages: messages,
      reasoning: %{
        effort: "minimal"
      }
    }

    case Req.post(req, url: "/chat/completions", json: chat_body) do
      {:ok, %Req.Response{status: status} = resp} when status in 200..299 ->
        {:ok, resp}
      {:ok, %Req.Response{} = resp} ->
        IO.inspect({:openrouter_http_error, resp.status, resp.body}, label: "OpenRouter error")
        {:error, {:openrouter_http_error, resp.status}}
      {:error, reason} ->
        IO.inspect(reason, label: "Req transport error")
        {:error, reason}
    end
  end
end
