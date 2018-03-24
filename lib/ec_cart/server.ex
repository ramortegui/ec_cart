defmodule EcCart.Server do

  alias EcCart.Item
  alias EcCart.Adjustment

  @moduledoc """
    Module to handle `EcCart` structures.
  """
  defstruct items: [], adjustments: []

  use GenServer

  @doc """
    Creates an empty %EcCart.Server{} structure, this strucure has by default 
    and empty list of items and and empty list of adjustments

    ## Examples

        iex> EcCart.Server.new
        %EcCart.Server{adjustments: [], items: []}

  """
  def new, do: %EcCart.Server{}

  @doc """
    Add a new item into the %EcCart{} structure, if the item already exists on the
    structure, this function will update the quantity.

    ## Examples
    
        iex> ec_cart = EcCart.Server.new
        iex> EcCart.Server.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
        %EcCart.Server{adjustments: [],items: [%EcCart.Item{attr: %{}, ec_price: 3, ec_qty: 10, ec_sku: "SU04"}]}

  """
  def add_item(%EcCart.Server{} = ec_cart, %EcCart.Item{} = ec_cart_item) do
    %{ec_cart | items: insert_or_update_item( ec_cart.items, ec_cart_item)}
  end

  defp insert_or_update_item(items, %EcCart.Item{ec_sku: ec_sku} = ec_cart_item) do
    case item_in_cart(items, ec_sku) do
      [] -> items ++ [ec_cart_item]
      [_] -> update_items(items, ec_cart_item)
    end
  end

  defp update_items(items, %EcCart.Item{ec_sku: ec_sku} = ec_cart_item) do
    Enum.map(items, fn
      %EcCart.Item{ec_sku: ^ec_sku} = item -> %EcCart.Item{ec_qty: item.qty + ec_cart_item.ec_qty}
      _ -> ec_cart_item
    end)
  end

  defp item_in_cart(items, ec_sku) do
    Enum.filter(items, fn item -> item.ec_sku == ec_sku end)
  end

  @doc """
    Add and adjutmens to the adjustment list.

    ## Examples

        iex> ec_cart = EcCart.Server.new
        iex> adj = EcCart.Adjustment.new(\"shipping\",\"Shipping\", 
        ...> fn(x) -> 
        ...> sb = EcCart.Server.subtotal(x)
        ...>  case sb do
        ...>    sb when sb > 25 -> 0
        ...>    _-> 10
        ...>   end
        iex> end)
        iex> ec_cart = EcCart.Server.add_adjustment(ec_cart,adj)
        iex> length ec_cart.adjustments
        1
  """
  def add_adjustment(%EcCart.Server{} = ec_cart, %EcCart.Adjustment{} = ec_cart_adjustment) do
    %EcCart.Server{ec_cart | adjustments: ec_cart.adjustments ++ [ec_cart_adjustment]}
  end

  @doc """
    Calculate the sum of the result of multiply the price of each item and its quantity
    
    ## Examples

        iex> ec_cart = EcCart.Server.new
        iex> ec_cart = EcCart.Server.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 2 })
        iex> EcCart.Server.subtotal(ec_cart)
        20

  """
  def subtotal(%EcCart.Server{items: items}) do
    Enum.reduce(items, 0, fn x, acc -> x.ec_qty * x.ec_price + acc end)
  end

  defp adjustment_value(%EcCart.Server{} = ec_cart, %EcCart.Adjustment{} = adjustment) do
    adjustment.function.(ec_cart)
  end

  @doc """
    Calculates the total of the cart that include: subtotal + adjustments

    ## Examples

      iex> ec_cart = EcCart.Server.new
      iex> ec_cart = EcCart.Server.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 5, ec_price: 3 })
      iex> adj = EcCart.Adjustment.new("shipping","Shipping", 
      ...> fn(x) -> 
      ...> sb = EcCart.Server.subtotal(x)
      ...>case sb do
      ...>  sb when sb > 25 -> 0
      ...>  _-> 10
      ...>end
      ...>end)
      iex> ec_cart = EcCart.Server.add_adjustment(ec_cart,adj)
      iex> EcCart.Server.total(ec_cart)
      25
  """
  def total(%EcCart.Server{} = ec_cart) do
    subtotal = EcCart.Server.subtotal(ec_cart)

    adjustments =
      Enum.reduce(ec_cart.adjustments, 0, fn x, acc ->
        adjustment_value(ec_cart, x) + acc
      end)

    subtotal + adjustments
  end

  def init(_) do
    {:ok, EcCart.new()}
  end

  def start_link do
    IO.puts("Starting ec_cart_server.")
    GenServer.start_link(EcCart.Server, nil)
  end

  def handle_cast({:add_item, item}, state) do
    {:noreply, EcCart.Server.add_item(state, item)}
  end

  def handle_cast({:add_adjustment, adjustment}, state) do
    {:noreply, EcCart.Server.add_adjustment(state, adjustment)}
  end

  def handle_call({:subtotal}, _, state) do
    {:reply, EcCart.Server.subtotal(state), state}
  end

  def handle_call({:total}, _, state) do
    {:reply, EcCart.Server.total(state), state}
  end


  def add_item(pid, item) do
    GenServer.cast(pid, {:add_item, item})
  end

  def add_adjustment(pid, adjustment) do
    GenServer.cast(pid, {:add_adjustment, adjustment})
  end

  def subtotal(pid) do
    GenServer.call(pid, {:subtotal})
  end

  def total(pid) do
    GenServer.call(pid, {:total})
  end
end
