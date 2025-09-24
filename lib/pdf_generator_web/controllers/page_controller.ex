defmodule PdfGeneratorWeb.PageController do
  use PdfGeneratorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
