defmodule ExCart.Application do
  use Application

  def start(_type, _args) do
    children = [
      ExCart.Cache,
      {DynamicSupervisor, strategy: :one_for_one, name: ExCart.Cart.Supervisor}
    ]

    opts = [
      strategy: :one_for_one,
      name: ExCart.Supervisor
    ]

    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
