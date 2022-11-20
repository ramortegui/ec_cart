defmodule ExCart.Supervisor do
  use Supervisor

  def init(:ok) do
    processes = [
      ExCart.Cache,
      ExCart.ServerSupervisor
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]

    Supervisor.init(processes, opts)
  end

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end
end
