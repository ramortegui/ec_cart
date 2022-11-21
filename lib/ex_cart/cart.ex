defmodule ExCart.Cart do
  @moduledoc """
    Module to handle `ExCart` structures.
  """
  defstruct items: [], adjustments: []

  @doc """
    Creates an empty %ExCart.Cart{} structure, this strucure has by default
    and empty list of items and and empty list of adjustments

    ## Examples

        iex> ExCart.Cart.new
        %ExCart.Cart{adjustments: [], items: []}

  """
  def new, do: %ExCart.Cart{}

  @doc """
    Add a new item into the %ExCart.Cart{} structure, if the item already exists on the
    structure, this function will update the quantity.

    ## Examples
    
        iex> ex_cart = ExCart.Cart.new
        iex> ExCart.Cart.add_item(ex_cart,%ExCart.Item{ sku: "SU04", qty: 10, price: 3 })
        %ExCart.Cart{adjustments: [],items: [%ExCart.Item{attr: %{}, price: 3, qty: 10, sku: "SU04"}]}

  """
  def add_item(%ExCart.Cart{} = ex_cart, %ExCart.Item{} = ex_cart_item) do
    %{ex_cart | items: insert_or_update_item(ex_cart.items, ex_cart_item)}
  end

  defp insert_or_update_item(items, %ExCart.Item{sku: sku} = ex_cart_item) do
    case item_in_cart(items, sku) do
      [] -> items ++ [ex_cart_item]
      [_] -> update_items(items, ex_cart_item)
    end
  end

  defp update_items(items, %ExCart.Item{sku: sku} = cart_item) do
    Enum.map(items, fn
      %ExCart.Item{sku: ^sku} = item ->
        %ExCart.Item{item | qty: item.qty + cart_item.qty}

      _ ->
        cart_item
    end)
  end

  defp item_in_cart(items, sku) do
    Enum.filter(items, fn item -> item.sku == sku end)
  end

  @doc """
    Clear items from the Cart.
  """
  def clear_items(%ExCart.Cart{items: items} = ex_cart) do
    %{ex_cart | items: []}
  end

  @doc """
    Clear the Cart.
  """
  def clear(%ExCart.Cart{items: items} = ex_cart) do
    cart = %{ex_cart | items: []}
    %{cart | adjustments: []}
  end

  @doc """
    Add adjustment to the adjustment list.

    ## Examples

        iex> ex_cart = ExCart.Cart.new
        iex> adj = ExCart.Adjustment.new(\"shipping\",\"Shipping\",
        ...> fn(x) ->
        ...> sb = ExCart.Cart.subtotal(x)
        ...>  case sb do
        ...>    sb when sb > 25 -> 0
        ...>    _-> 10
        ...>   end
        iex> end)
        iex> ex_cart = ExCart.Cart.add_adjustment(ex_cart,adj)
        iex> length ex_cart.adjustments
        1
  """
  def add_adjustment(%ExCart.Cart{} = ex_cart, %ExCart.Adjustment{} = ex_cart_adjustment) do
    %ExCart.Cart{ex_cart | adjustments: ex_cart.adjustments ++ [ex_cart_adjustment]}
  end

  @doc """
    Remove adjustment from adjustment list.

    ## Examples

    iex> ex_cart = ExCart.Cart.new
    iex> adj = ExCart.Adjustment.new(\"shipping\",\"Shipping\",
    ...> fn(x) ->
    ...> sb = ExCart.Cart.subtotal(x)
    ...>  case sb do
    ...>    sb when sb > 25 -> 0
    ...>    _-> 10
    ...>   end
    iex> end)
    iex> ex_cart = ExCart.Cart.add_adjustment(ex_cart, adj)
    iex> length ex_cart.adjustments
    1
    iex> ex_cart = ExCart.Cart.remove_adjustment(ex_cart, \"shipping\")
    iex> length ex_cart.adjustments
    0
  """

  def remove_adjustment(%ExCart.Cart{adjustments: adjustments} = ex_cart, adj) do
    adjustments = Enum.reject(adjustments, &(&1.name == adj))
    %{ex_cart | adjustments: adjustments}
  end

  @doc """
    Get the Adjustment.
  """
  def get_adjustment(
        %ExCart.Cart{adjustments: adjustments} = ex_cart,
        %ExCart.Adjustment{name: name} = ex_cart_adjustment
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    {:ok, adjustment}
  end

  @doc """
    Get the Adjustment Result.
  """
  def get_adjustment_result(
        %ExCart.Cart{adjustments: adjustments} = ex_cart,
        %ExCart.Adjustment{name: name} = ex_cart_adjustment
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    adjustment_result = adjustment_result(ex_cart, adjustment)
    {:ok, adjustment_result}
  end

  @doc """
    Clear adjustments from the Cart.
  """
  def clear_adjustments(%ExCart.Cart{adjustments: adjustments} = ex_cart) do
    %{ex_cart | adjustments: []}
  end

  @doc """
    Calculate the sum of the result of multiply the price of each item and its quantity
    
    ## Examples

        iex> ex_cart = ExCart.Cart.new
        iex> ex_cart = ExCart.Cart.add_item(ex_cart,%ExCart.Item{ sku: "SU04", qty: 10, price: 2 })
        iex> ExCart.Cart.subtotal(ex_cart)
        20

  """
  def subtotal(%ExCart.Cart{items: items}) do
    Enum.reduce(items, 0, fn x, acc -> x.ec_qty * x.ec_price + acc end)
  end

  defp adjustment_value(%ExCart.Cart{} = ex_cart, %ExCart.Adjustment{} = adjustment) do
    adjustment.function.(ex_cart)
  end

  defp adjustment_result(%ExCart.Cart{} = ex_cart, adjustment) do
    subtotal = ExCart.Cart.subtotal(ex_cart)

    adjustment_value = adjustment_value(ex_cart, adjustment)

    adjustment = Map.put(adjustment, :adjustment_value, adjustment_value)

    {:ok, %{subtotal: subtotal, adjustment: adjustment}}
  end

  @doc """
    Calculates the total of the cart that include: subtotal + adjustments

    ## Examples

      iex> ex_cart = ExCart.Cart.new
      iex> ex_cart = ExCart.Cart.add_item(ex_cart,%ExCart.Item{ sku: "SU04", qty: 5, price: 3 })
      iex> adj = ExCart.Adjustment.new("shipping","Shipping",
      ...> fn(x) -> 
      ...> sb = ExCart.Cart.subtotal(x)
      ...>case sb do
      ...>  sb when sb > 25 -> 0
      ...>  _-> 10
      ...>end
      ...>end)
      iex> ex_cart = ExCart.Cart.add_adjustment(ex_cart, adj)
      iex> ExCart.Cart.total(ex_cart)
      25
  """
  def total(%ExCart.Cart{} = ex_cart) do
    subtotal = ExCart.Cart.subtotal(ex_cart)

    adjustments =
      Enum.reduce(ex_cart.adjustments, 0, fn x, acc ->
        adjustment_value(ex_cart, x) + acc
      end)

    subtotal + adjustments
  end
end
