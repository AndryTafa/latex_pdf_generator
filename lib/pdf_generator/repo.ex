defmodule PdfGenerator.Repo do
  use Ecto.Repo,
    otp_app: :pdf_generator,
    adapter: Ecto.Adapters.Postgres
end
