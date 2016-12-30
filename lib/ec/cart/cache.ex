defmodule Ec.Cart.Cache do
  use GenServer
  def start do
    GenServer.start(__MODULE__, nil)
  end

  def server_process(cache_pid, ec_cart_server_name ) do
    GenServer.call(cache_pid, {:server_process, ec_cart_server_name})
  end

  def init(_) do
    {:ok, Map.new }
  end

  def handle_call({:server_process, ec_cart_server_name }, _, ec_cart_servers ) do
    case Map.fetch(ec_cart_servers, ec_cart_server_name) do
      {:ok, ec_cart_server} ->
        { :reply, ec_cart_server, ec_cart_servers }
      :error ->
        {:ok, new_ec_cart_server} = Ec.Cart.Server.start

        { :reply, new_ec_cart_server, Map.put(ec_cart_servers, ec_cart_server_name, new_ec_cart_server) }
    end
  end
end
