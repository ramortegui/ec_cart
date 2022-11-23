defmodule ExCart.Cache do
  @registry_name :ex_cart_registry

  alias ExCart.Registry

  def register(ex_cart_server_name) do
    Registry.register(ex_cart_server_name)
  end

  def server_process(ex_cart_server_name) do
    via_tuple(ex_cart_server_name)
  end

  def remove_process(ex_cart_server_name) do
    Registry.unregister(ex_cart_server_name)
  end

  def via_tuple(name) do
    {:via, Registry, {@registry_name, name}}
  end
end
