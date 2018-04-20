defmodule EcCart.Cache do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  def server_process(ec_cart_server_name) do
    GenServer.call(__MODULE__, {:server_process, ec_cart_server_name})
  end

  def remove_process(ec_cart_server_name) do
    GenServer.cast(__MODULE__, {:remove_process, ec_cart_server_name})
  end

  def init(_) do
    {:ok, Map.new()}
  end

  def handle_call({:server_process, ec_cart_name}, _, ec_cart_servers) do
    case Map.fetch(ec_cart_servers, ec_cart_name) do
      {:ok, ec_cart_server} ->
        {:reply, ec_cart_server, ec_cart_servers}

      :error ->
        {:ok, ec_cart_server} = EcCart.ServerSupervisor.start_cart()
        {:reply, ec_cart_server, Map.put(ec_cart_servers, ec_cart_name, ec_cart_server)}
    end
  end

  def handle_cast({:remove_process, ec_cart_name}, ec_cart_servers) do
    case Map.fetch(ec_cart_servers, ec_cart_name) do
      {:ok, ec_cart_server} ->
        EcCart.ServerSupervisor.remove_cart(ec_cart_server)
        {:noreply, Map.delete(ec_cart_servers, ec_cart_name)}

      :error ->
        {:noreply, ec_cart_servers, ec_cart_servers}
    end
  end
end
