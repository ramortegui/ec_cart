defmodule Ec.Cart.Server do
  use GenServer

  def init(_) do
    {:ok, Ec.Cart.new }
  end

  def handle_cast({:add_item, item}, state) do
    {:noreply, Ec.Cart.add_item(state, item)}
  end

  def handle_cast({:add_adjustment, adjustment}, state) do
    {:noreply, Ec.Cart.add_adjustment(state, adjustment)}
  end

  def handle_call({:subtotal}, _, state) do
    {:reply, Ec.Cart.subtotal(state), state }
  end

  def handle_call({:total}, _, state) do
    {:reply, Ec.Cart.total(state), state }
  end

  def start_link do
    IO.puts "Starting ec_cart_server."
    GenServer.start_link(Ec.Cart.Server, nil)
  end

  def add_item( pid, item) do
    GenServer.cast(pid, {:add_item, item })
  end

  def add_adjustment( pid, adjustment ) do
    GenServer.cast(pid, {:add_adjustment, adjustment} )
  end

  def subtotal( pid ) do
    GenServer.call(pid, {:subtotal})
  end

  def total( pid ) do
    GenServer.call(pid, {:total})
  end
end
