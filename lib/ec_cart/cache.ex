defmodule EcCart.Cache do
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: :ec_cart_cache)
  end

  def server_process(ec_cart_server_name) do
    GenServer.call(:ec_cart_cache, {:server_process, ec_cart_server_name})
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
end
