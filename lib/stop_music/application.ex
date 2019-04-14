defmodule StopMusic.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # List all child processes to be supervised
    children = [
      #{StopMusic.Worker, "/dev/cu.HC-05-SPPDev"},
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: StopMusic.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
