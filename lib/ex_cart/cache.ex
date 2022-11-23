defmodule ExCart.Cache do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(ex_cart_server_name) do
    GenServer.call(__MODULE__, {:server_process, ex_cart_server_name})
  end

  def remove_process(ex_cart_server_name) do
    GenServer.cast(__MODULE__, {:remove_process, ex_cart_server_name})
  end

  def init(_) do
    {:ok, Map.new()}
  end

  def handle_call({:server_process, ex_cart_name}, _, ex_cart_servers) do
    case Map.fetch(ex_cart_servers, ex_cart_name) do
      {:ok, ex_cart_server} ->
        {:reply, ex_cart_server, ex_cart_servers}

      :error ->
        {:ok, ex_cart_server} = ExCart.Cart.Supervisor.start_cart()
        {:reply, ex_cart_server, Map.put(ex_cart_servers, ex_cart_name, ex_cart_server)}
    end
  end

  def handle_cast({:remove_process, ex_cart_name}, ex_cart_servers) do
    case Map.fetch(ex_cart_servers, ex_cart_name) do
      {:ok, ex_cart_server} ->
        ExCart.Cart.Supervisor.remove_cart(ex_cart_server)
        new_cart_servers = Map.delete(ex_cart_servers, ex_cart_name)
        {:noreply, new_cart_servers}

      :error ->
        {:noreply, ex_cart_servers, ex_cart_servers}
    end
  end
end
