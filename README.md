# LaTeX PDF Generator

This project is a web application built with the Phoenix framework that dynamically generates LaTeX-based PDFs using AI. Users can provide instructions or context, and the application leverages an AI model (OpenRouter) to produce tailored LaTeX code, which is then compiled into a PDF.

## What is LaTeX ?
LaTeX is a way to write documents using plain text plus simple commands, which a compiler then turns into a clean, professional-looking PDF.
It’s especially good for math, scientific papers, and long documents because it handles formulas, references, and consistent formatting for you. People use it when they want precise, reliable typesetting without fighting a word processor’s formatting quirks.

Note: The UI is very bare bones, as my main focus was to get familiar with Elixir and Phoenix.

Example usage:
<img width="1203" height="584" alt="image" src="https://github.com/user-attachments/assets/91aa9545-b3b2-447e-bcdb-f396746c3bc8" />
-> This prompt will then be sent to the AI, which will generate a LaTeX style string such as this: 
```latex
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[a4paper, margin=1in]{geometry}
\usepackage{xcolor}
\usepackage{listings}
\usepackage{titlesec}
\usepackage{hyperref}
\usepackage{graphicx}
\usepackage{float}
\usepackage{parskip}

\definecolor{codebg}{RGB}{245,245,255}
\definecolor{codegray}{RGB}{80,80,80}
\definecolor{codeblue}{RGB}{0,80,160}
\definecolor{pink}{RGB}{255,192,203}

\lstdefinestyle{pykids}{
  backgroundcolor=\color{codebg},
  basicstyle=\ttfamily\small,
  keywordstyle=\color{codeblue}\bfseries,
  commentstyle=\color{codegray}\itshape,
[...]
```
-> This will then be sent to the LaTeX distribution that should be installed in the system, in this case texlive.
This will be achieved via a poolboy worker as specified in the Application.ex

```elixir
  # 8 (up to 10) pdf generation MAX, put the rest in a queue, to avoid exhausting system resources
  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: PdfGenerator.Worker,
      size: 8,
      max_overflow: 2
    ]
  end
```
And via the texlive system command run on the server, this would be the resulting pdf:
<img width="1096" height="1269" alt="image" src="https://github.com/user-attachments/assets/934e72c3-1f00-4c16-a0a3-7a3e0e061461" />
<img width="1120" height="1327" alt="image" src="https://github.com/user-attachments/assets/51c65f59-9058-4845-8e1c-7e95183c0287" />
<img width="1067" height="1254" alt="image" src="https://github.com/user-attachments/assets/ada7f1ba-e0ff-401d-b4f2-fb5ae369734e" />


## Usefulness

This generator can be incredibly useful in various scenarios:

*   **Educational Purposes:** Students and educators can use it to quickly generate LaTeX documents for specific topics. For example, an input like "write all the formulas to calculate the area for various polygons. The purpose is to teach kids." would generate a LaTeX document outlining these formulas in an understandable format.
*   **Automated Document Creation:** For any domain where LaTeX is used, this tool can automate the creation of structured documents based on textual input, saving time and ensuring consistency.
*   **Prototyping and Experimentation:** Developers and researchers can rapidly prototype LaTeX documents for reports, papers, or presentations without manually writing complex LaTeX code.

## Tech Stack

*   **Phoenix Framework:** The foundation of the web application, providing a robust and scalable platform for building interactive experiences.
*   **Phoenix LiveView:** Used to build rich, real-time user interfaces with server-rendered HTML, enabling dynamic updates without writing custom JavaScript.
*   **Req (HTTP Client):** Utilized for making external HTTP requests, specifically for communicating with the OpenRouter AI API.
*   **Poolboy (Process Pool):** To allow only for an N amount of workers, once all of the workers are busy, the rest of the processes will be put in a queue 
*   **OpenRouter (AI Integration):** The core AI service used to transform user instructions into LaTeX code. The application integrates with OpenRouter's API to generate dynamic LaTeX content.
*   **LaTeX Distribution:** A LaTeX distribution (e.g., TeX Live) is used on the server-side to compile the generated LaTeX code into PDF documents.

## Getting Started

To start your Phoenix server:

*   Run `mix setup` to install and setup dependencies
*   Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Install System dependencies
* texlive (LaTeX distribution - 4GB storage required)

### Dependencies instructions for Unix-like OS (linux/macos)

```bash
curl -O https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
```

```bash
tar -xzf install-tl-unx.tar.gz
```

```bash
cd install-tl-*
```

```bash
sudo perl install-tl
```
Note: The UI is very bare bones, as my main focus was to get familiar with Elixir and Phoenix.

Example usage:
<img width="1203" height="584" alt="image" src="https://github.com/user-attachments/assets/91aa9545-b3b2-447e-bcdb-f396746c3bc8" />
This prompt will then be sent to the AI, which will generate a LaTeX style string such as this: 
```latex
\documentclass[11pt]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage{lmodern}
\usepackage[a4paper, margin=1in]{geometry}
\usepackage{xcolor}
\usepackage{listings}
\usepackage{titlesec}
\usepackage{hyperref}
\usepackage{graphicx}
\usepackage{float}
\usepackage{parskip}

\definecolor{codebg}{RGB}{245,245,255}
\definecolor{codegray}{RGB}{80,80,80}
\definecolor{codeblue}{RGB}{0,80,160}
\definecolor{pink}{RGB}{255,192,203}

\lstdefinestyle{pykids}{
  backgroundcolor=\color{codebg},
  basicstyle=\ttfamily\small,
  keywordstyle=\color{codeblue}\bfseries,
  commentstyle=\color{codegray}\itshape,
[...]
```
This will then be sent to the LaTeX distribution that should be installed in the system, in this case texlive.
This will be achieved via a poolboy worker as specified in the Application.ex
```elixir
# LaTeX PDF Generator

This project is a web application built with the Phoenix framework that dynamically generates LaTeX-based PDFs using AI. Users can provide instructions or context, and the application leverages an AI model (OpenRouter) to produce tailored LaTeX code, which is then compiled into a PDF.

## What is LaTeX ?
LaTeX is a way to write documents using plain text plus simple commands, which a compiler then turns into a clean, professional-looking PDF.
It’s especially good for math, scientific papers, and long documents because it handles formulas, references, and consistent formatting for you. People use it when they want precise, reliable typesetting without fighting a word processor’s formatting quirks.

## Usefulness

This generator can be incredibly useful in various scenarios:

*   **Educational Purposes:** Students and educators can use it to quickly generate LaTeX documents for specific topics. For example, an input like "write all the formulas to calculate the area for various polygons. The purpose is to teach kids." would generate a LaTeX document outlining these formulas in an understandable format.
*   **Automated Document Creation:** For any domain where LaTeX is used, this tool can automate the creation of structured documents based on textual input, saving time and ensuring consistency.
*   **Prototyping and Experimentation:** Developers and researchers can rapidly prototype LaTeX documents for reports, papers, or presentations without manually writing complex LaTeX code.

## Tech Stack

*   **Phoenix Framework:** The foundation of the web application, providing a robust and scalable platform for building interactive experiences.
*   **Phoenix LiveView:** Used to build rich, real-time user interfaces with server-rendered HTML, enabling dynamic updates without writing custom JavaScript.
*   **Req (HTTP Client):** Utilized for making external HTTP requests, specifically for communicating with the OpenRouter AI API.
*   **Poolboy (Process Pool):** To allow only for an N amount of workers, once all of the workers are busy, the rest of the processes will be put in a queue 
*   **OpenRouter (AI Integration):** The core AI service used to transform user instructions into LaTeX code. The application integrates with OpenRouter's API to generate dynamic LaTeX content.
*   **LaTeX Distribution:** A LaTeX distribution (e.g., TeX Live) is used on the server-side to compile the generated LaTeX code into PDF documents.

## Getting Started

To start your Phoenix server:

*   Run `mix setup` to install and setup dependencies
*   Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Install System dependencies
* texlive (LaTeX distribution - 4GB storage required)

### Dependencies instructions for Unix-like OS (linux/macos)

```bash
curl -O https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
```

```bash
tar -xzf install-tl-unx.tar.gz
```

```bash
cd install-tl-*
```

```bash
sudo perl install-tl
```
