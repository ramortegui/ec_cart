defmodule EcCart.Supervisor do
  use Supervisor

  def init(:ok) do
    processes = [worker(EcCart.Cache, [])]
    supervise(processes, strategy: :one_for_one)
  end

  def start_link(_arg) do
    Supervisor.start_link(__MODULE__, :ok, [])
  end
end
