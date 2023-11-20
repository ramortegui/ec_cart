defmodule ExCart.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
    ExCart.Session,
    {DynamicSupervisor, strategy: :one_for_one, name: :ex_cart_supervisor}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ExCart.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
