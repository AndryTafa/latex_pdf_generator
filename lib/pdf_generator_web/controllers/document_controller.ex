defmodule PdfGeneratorWeb.DocumentController do
  use PdfGeneratorWeb, :controller

  def generate_document_pdf(conn, %{"document_context" => document_context}) do
    _user = conn.assigns.current_scope.user

    # The template is now handled directly by the AI based on the context
    _deleteme_template = """
      %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
      \\documentclass[10pt, letterpaper]{article}

      \\usepackage[ignoreheadfoot,top=1.2cm,bottom=1.2cm,left=1.5cm,right=1.5cm,footskip=0.8cm]{geometry}
      \\usepackage{titlesec}
      \\usepackage{tabularx}
      \\usepackage{array}
      \\usepackage[dvipsnames]{xcolor}
      \\definecolor{primaryColor}{RGB}{0, 0, 0}
      \\usepackage{enumitem}
      \\usepackage{fontawesome5}
      \\usepackage[
        pdftitle={Document (Identifying details intentionally hidden)},
        pdfauthor={redacted},
        colorlinks=true,
        urlcolor=primaryColor
      ]{hyperref}
      \\usepackage{paracol}
      \\usepackage{charter}

      \\raggedright
      \\pagestyle{empty}
      \\setcounter{secnumdepth}{0}
      \\setlength{\\parindent}{0pt}
      \\setlength{\\columnsep}{0.15cm}

      \\titleformat{\\section}{\\Large\\bfseries}{}{0pt}{}[\\vspace{1pt}\\titlerule]
      \\titlespacing{\\section}{0pt}{0.3cm}{0.2cm}

      \\newenvironment{cvlist}{
          \\begin{itemize}[
              leftmargin=*,
              itemsep=0.08cm,
              parsep=0pt
          ]
      }{
          \\end{itemize}
      }

      \\newenvironment{roleheader}[2]{
          \\textbf{#1} \\hfill #2 \\\\[-0.1cm]
      }{
      }

      \\begin{document}

      % Header
      \\begin{center}
          \\Huge\\textbf{Replace this with name and surname}
          
          \\vspace{0.2cm}
          \\normalsize
          replace Location if available \\textbar{} Phone number here\\textbar{} email@example.com
          
          \\vspace{0.1cm}
          \\href{https://github.com/randomgithub}{github.com/randomgithub} % put any socials or other links here if appropriate
      \\end{center}

      % Professional Summary
      \\section{Professional Summary}
      Here put a introduction of the candidate. Around 82 words/630 characters roughly

      % Experience
      \\section{Professional Experience}

      %You can repeat the code below, from the begin to the end tag for multiple entries and change descriptions, etc.... accordingly depending on the entries
      \\begin{roleheader}{A document entry title here }{Date here, if still working: starting date – Present}\n\\end{roleheader}\n\\textit{You can remove this, but if available, put a very short description of the company, e.g. Enterprise B2B systems} %Make sure to use textbf tags to highlight keywords that fit the description\n\\begin{cvlist}\n          \\item Here, you can reuse the item tag to list a bunch of things from this entry\n\\end{cvlist}\n
      % Technical Skills, this is pretty self-explanatory, you can reuse the item tags again to list a bunch of things, I will leave a couple for reference\n      \\section{Technical Skills}\n\\begin{cvlist}\n          \\item \\textbf{Software Lifecycle:} Agile (4+ years, SCRUM), Waterfall, complete SDLC expertise from requirements to maintenance\n          \\item \\textbf{Version Control \\& Configuration Management:} Git (advanced), branching strategies (GitFlow), Docker containerization, environment management, CI/CD practices\n\\end{cvlist}\n
      % Key Projects, again, self-explanatory, you get the idea by now, just add as many projects etc.. as needed, I will leave one for reference\n      \\section{Key Projects \\& Technical Implementations}\n
      \\textbf{Freelance Projects (Current)}\n\\begin{cvlist}\n          \\item Self-Service Kiosk Platform — architecting complete ecosystem with offline-first design ensuring continuous operation\n          \\item Various web applications and API integrations for startup and enterprise clients\n          \\item Building robust synchronization mechanisms and real-time monitoring interfaces\n\\end{cvlist}\n
      % Latest Personal Projects, same thing as explained above\n      \\section{Latest Personal Project}\n      \\textbf{Multitenancy Personal RAG System}\n\\begin{cvlist}\n          \\item End-to-end note capture and semantic retrieval platform built with \\textbf{Laravel}, \\textbf{Vue}, and \\textbf{Inertia}; OCR via \\textbf{Google Vision} (including handwritten text), embeddings with \\textbf{OpenAI}, vector search in \\textbf{Qdrant}, and \\textbf{AWS S3} object storage\n          \\item Designed ingestion and retrieval flows: content chunking, embedding, metadata filtering, and more; \\textbf{multi-tenancy} with strict per-user isolation across metadata, storage, and vector search\n          \\item For additional personal projects, please see my GitHub (link above)\n\\end{cvlist}\n
      % Education\n      \\section{Education}\n\\begin{roleheader}{Level 4 Software Development Apprenticeship, Just IT --- London}{}\n\\end{roleheader}\n\\vspace{0.1cm}\nEducation here, either courses, university, whatever you have been given that would fit well in this section\n\\begin{cvlist}\n          \\item System Design \\& Architecture — creating scalable solutions using established design patterns and principles\n          \\item Version Control Systems — extensive hands-on experience with Git and collaborative workflows\n          \\item Configuration Management — environment management, containerization, and deployment strategies\n          \\item Software Testing — comprehensive coverage of TDD, unit testing, and integration testing methodologies\n          \\item Professional Practices — code reviews, documentation standards, and agile ceremony participation\n\\end{cvlist}\n\\end{document}"
    """

    case generate_document_pdf_content(document_context) do
      {:ok, pdf_binary} ->
        conn
        |> put_resp_content_type("application/pdf")
        |> put_resp_header("content-disposition", "attachment; filename=\"document.pdf\"")
        |> send_resp(200, pdf_binary)

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "Failed to generate PDF: #{inspect(reason)}"})
    end
  end

  defp generate_document_pdf_content(document_context) do
    _start_time = System.monotonic_time(:millisecond)

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

    # _duration = System.monotonic_time(:millisecond) - start_time
    # IO.puts("Document generation took #{_duration}ms")

    result
  end

  defp extract_latex_from_response(%Req.Response{body: body}) do
    body["choices"]
    |> List.first()
    |> get_in(["message", "content"])
  end
end
