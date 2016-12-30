defmodule EcCartServer do
  use GenServer

  def init(_) do
    {:ok, EcCart.new }
  end

  def handle_cast({:add_item, item}, state) do
    {:noreply, EcCart.add_item(state, item)}
  end

  def handle_cast({:add_adjustment, adjustment}, state) do
    {:noreply, EcCart.add_adjustment(state, adjustment)}
  end

  def handle_call({:subtotal}, _, state) do
    {:reply, EcCart.subtotal(state), state }
  end

  def handle_call({:total}, _, state) do
    {:reply, EcCart.total(state), state }
  end

  def start do
    GenServer.start(EcCartServer, nil)
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
