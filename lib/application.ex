defmodule ExCart.Application do
  use Application

  @name __MODULE__

  def start(_type, _args) do
    children = [
      ExCart.Session,
      {DynamicSupervisor, strategy: :one_for_one, name: :ex_cart_supervisor}
    ]

    opts = [
      strategy: :one_for_one,
      name: @name
    ]

    Supervisor.start_link(children, opts)
  end

  @version Mix.Project.config()[:version]
  def version, do: @version
end
