defmodule PdfGenerator.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # 8 (up to 10) pdf generation MAX, put the rest in a queue, to avoid exhausting system resources
  defp poolboy_config do
    [
      name: {:local, :worker},
      worker_module: PdfGenerator.Worker,
      size: 8,
      max_overflow: 2
    ]
  end

  @impl true
  def start(_type, _args) do
    children = [
      PdfGeneratorWeb.Telemetry,
      PdfGenerator.Repo,
      {DNSCluster, query: Application.get_env(:pdf_generator, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PdfGenerator.PubSub},
      # Start a worker by calling: PdfGenerator.Worker.start_link(arg)
      # {PdfGenerator.Worker, arg},
      # Start to serve requests, typically the last entry
      PdfGeneratorWeb.Endpoint,
      :poolboy.child_spec(:worker, poolboy_config())
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PdfGenerator.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PdfGeneratorWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
