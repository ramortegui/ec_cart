defmodule EcCart.Supervisor do
  use Supervisor

  def start_link(_arg) do
    processes = [
      EcCart.Cache,
      EcCart.ServerSupervisor
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.start_link(processes, opts)
  end
end
