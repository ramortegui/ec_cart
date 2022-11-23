defmodule ExCart.Cart.Supervisor do
  use DynamicSupervisor

  @name __MODULE__

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def init(args) do
    DynamicSupervisor.init(
      strategy: :one_for_one,
      extra_arguments: args
    )
  end

  def start_link(_args) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: @name)
  end

  def start_cart do
    child_spec = %{
      id: ExCart.Server,
      start: {ExCart.Server, :start_link, []},
      restart: :transient
    }

    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end

  def remove_cart(pid) do
    DynamicSupervisor.terminate_child(__MODULE__, pid)
  end
end
