defmodule ExCart.Cart do
  @moduledoc """
    Module to handle `ExCart` structures.
  """

  defstruct items: [], adjustments: []

  @max_items Application.compile_env(:ex_cart, :max_items, 1000)

  @doc """
    Creates an empty %ExCart.Cart{} structure, this structure has by default
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
  def add_item(%ExCart.Cart{} = ex_cart, %ExCart.Item{} = cart_item) do
    %{ex_cart | items: insert_or_update_item(ex_cart.items, cart_item)}
  end

  defp insert_or_update_item(items, %ExCart.Item{sku: sku} = cart_item) do
    case item_in_cart(items, sku) do
      [] ->
        if Enum.count(items) < @max_items do
          items ++ [cart_item]
        else
          items
        end

      [_] ->
        update_items(items, cart_item)
    end
  end

  defp update_items(items, %ExCart.Item{sku: sku} = cart_item) do
    items =
      Enum.map(items, fn
        %ExCart.Item{sku: ^sku} = item ->
          %ExCart.Item{item | qty: item.qty + cart_item.qty}

        _ ->
          cart_item
      end)

    if Enum.count(items) > @max_items do
      {_, updated_items} = List.pop_at(items, -1)
      updated_items
    end
  end

  defp item_in_cart(items, sku) do
    Enum.filter(items, fn item -> item.sku == sku end)
  end

  @doc """
    Clear items from the Cart.
  """
  def clear_items(cart) do
    %{cart | items: []}
  end

  @doc """
    Clear the Cart.
  """
  def clear(cart) do
    cart = %{cart | items: []}
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
  def add_adjustment(%ExCart.Cart{} = cart, %ExCart.Adjustment{} = adjustment) do
    %ExCart.Cart{cart | adjustments: cart.adjustments ++ [adjustment]}
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
    iex> ex_cart = ExCart.Cart.remove_adjustment(ex_cart, "shipping")
    iex> length ex_cart.adjustments
    0
  """

  def remove_adjustment(%ExCart.Cart{adjustments: adjustments} = cart, adj) do
    adjustments = Enum.reject(adjustments, &(&1.name == adj))
    %{cart | adjustments: adjustments}
  end

  @doc """
    Get the Adjustment.
  """
  def get_adjustment(
        %ExCart.Cart{adjustments: adjustments} = _cart,
        %ExCart.Adjustment{name: name} = _adjustment
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    {:ok, adjustment}
  end

  @doc """
    Get the Adjustment Result.
  """
  def get_adjustment_result(
        %ExCart.Cart{adjustments: adjustments} = cart,
        %ExCart.Adjustment{name: name} = _adjustment
      ) do
    adjustment = Enum.reject(adjustments, &(&1.name == name))
    adjustment_result = adjustment_result(cart, adjustment)
    {:ok, adjustment_result}
  end

  @doc """
    Clear adjustments from the Cart.
  """
  def clear_adjustments(%ExCart.Cart{adjustments: _adjustments} = cart) do
    %{cart | adjustments: []}
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
    Enum.reduce(items, 0, fn x, acc -> x.qty * x.price + acc end)
  end

  defp adjustment_value(%ExCart.Cart{} = cart, %ExCart.Adjustment{} = adjustment) do
    adjustment.function.(cart)
  end

  defp adjustment_result(%ExCart.Cart{} = cart, adjustment) do
    subtotal = ExCart.Cart.subtotal(cart)

    adjustment_value = adjustment_value(cart, adjustment)

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
  def total(%ExCart.Cart{} = cart) do
    subtotal = ExCart.Cart.subtotal(cart)

    adjustments =
      Enum.reduce(cart.adjustments, 0, fn x, acc ->
        adjustment_value(cart, x) + acc
      end)

    subtotal + adjustments
  end
end
