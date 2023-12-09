defmodule ExCart.Session do
  @moduledoc false

  @name :ex_cart_sessions

  def child_spec([]) do
    %{
      id: __MODULE__,
      type: :worker,
      start: {__MODULE__, :start_link, []}
    }
  end

  @doc """
  Starts the registry
  """
  @spec start_link() :: {:ok, pid} | {:error, reason :: any}
  def start_link do
    Registry.start_link(keys: :unique, name: @name)
  end

  @doc """
  Registers the channel with the name
  """
  @spec register(String.t()) :: :ok | {:duplicate_key, pid}
  def register(name, value \\ nil) do
    @name
    |> Registry.register(name, value)
    |> case do
      {:ok, _pid} ->
        :ok

      {:error, {:already_registered, pid}} ->
        {:duplicate_key, pid}
    end
  end

  def unregister(name) do
    @name
    |> Registry.unregister(name)
    |> case do
      {:ok, _pid} ->
        :ok

      {:error, {:already_registered, pid}} ->
        {:duplicate_key, pid}
    end
  end

  @doc """
  Looks up the given name
  """
  @spec lookup(String.t()) :: {:ok, pid} | :not_found
  def lookup(name) do
    @name
    |> Registry.lookup(name)
    |> case do
      [] -> :not_found
      [{pid, nil}] -> {:ok, pid}
    end
  end

  def server_process(name) do
    via_tuple(name)
  end

  def remove_process(name) do
    Registry.unregister(@name, name)
  end

  def via_tuple(name, registry \\ @name) do
    {:via, Registry, {registry, name}}
  end
end
