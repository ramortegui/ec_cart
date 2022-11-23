defmodule ExCart.Cache do
  @registry_name :ex_cart_registry

  alias ExCart.Registry, as: EXCART_REGISTRY

  def register(ex_cart_server_name) do
    EXCART_REGISTRY.register(ex_cart_server_name)
  end

  def server_process(ex_cart_server_name) do
    via_tuple(ex_cart_server_name)
  end

  def remove_process(ex_cart_server_name) do
    Registry.unregister(@registry_name, ex_cart_server_name)
  end

  def via_tuple(name, registry \\ @registry_name) do
    {:via, Registry, {registry, name}}
  end
end
