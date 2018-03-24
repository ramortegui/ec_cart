defmodule EcCart.Cart do
  @moduledoc """
    Module to handle `EcCart` structures.
  """
  defstruct items: [], adjustments: []

  @doc """
    Creates an empty %EcCart.Cart{} structure, this strucure has by default 
    and empty list of items and and empty list of adjustments

    ## Examples

        iex> EcCart.Cart.new
        %EcCart.Cart{adjustments: [], items: []}

  """
  def new, do: %EcCart.Cart{}

  @doc """
    Add a new item into the %EcCart.Cart{} structure, if the item already exists on the
    structure, this function will update the quantity.

    ## Examples
    
        iex> ec_cart = EcCart.Cart.new
        iex> EcCart.Cart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
        %EcCart.Cart{adjustments: [],items: [%EcCart.Item{attr: %{}, ec_price: 3, ec_qty: 10, ec_sku: "SU04"}]}

  """
  def add_item(%EcCart.Cart{} = ec_cart, %EcCart.Item{} = ec_cart_item) do
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
      %EcCart.Item{ec_sku: ^ec_sku} = item -> %EcCart.Item{ item | ec_qty: item.ec_qty + ec_cart_item.ec_qty}
      _ -> ec_cart_item
    end)
  end

  defp item_in_cart(items, ec_sku) do
    Enum.filter(items, fn item -> item.ec_sku == ec_sku end)
  end

  @doc """
    Add and adjutmens to the adjustment list.

    ## Examples

        iex> ec_cart = EcCart.Cart.new
        iex> adj = EcCart.Adjustment.new(\"shipping\",\"Shipping\", 
        ...> fn(x) -> 
        ...> sb = EcCart.Cart.subtotal(x)
        ...>  case sb do
        ...>    sb when sb > 25 -> 0
        ...>    _-> 10
        ...>   end
        iex> end)
        iex> ec_cart = EcCart.Cart.add_adjustment(ec_cart,adj)
        iex> length ec_cart.adjustments
        1
  """
  def add_adjustment(%EcCart.Cart{} = ec_cart, %EcCart.Adjustment{} = ec_cart_adjustment) do
    %EcCart.Cart{ec_cart | adjustments: ec_cart.adjustments ++ [ec_cart_adjustment]}
  end

  @doc """
    Calculate the sum of the result of multiply the price of each item and its quantity
    
    ## Examples

        iex> ec_cart = EcCart.Cart.new
        iex> ec_cart = EcCart.Cart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 2 })
        iex> EcCart.Cart.subtotal(ec_cart)
        20

  """
  def subtotal(%EcCart.Cart{items: items}) do
    Enum.reduce(items, 0, fn x, acc -> x.ec_qty * x.ec_price + acc end)
  end

  defp adjustment_value(%EcCart.Cart{} = ec_cart, %EcCart.Adjustment{} = adjustment) do
    adjustment.function.(ec_cart)
  end

  @doc """
    Calculates the total of the cart that include: subtotal + adjustments

    ## Examples

      iex> ec_cart = EcCart.Cart.new
      iex> ec_cart = EcCart.Cart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 5, ec_price: 3 })
      iex> adj = EcCart.Adjustment.new("shipping","Shipping", 
      ...> fn(x) -> 
      ...> sb = EcCart.Cart.subtotal(x)
      ...>case sb do
      ...>  sb when sb > 25 -> 0
      ...>  _-> 10
      ...>end
      ...>end)
      iex> ec_cart = EcCart.Cart.add_adjustment(ec_cart,adj)
      iex> EcCart.Cart.total(ec_cart)
      25
  """
  def total(%EcCart.Cart{} = ec_cart) do
    subtotal = EcCart.Cart.subtotal(ec_cart)

    adjustments =
      Enum.reduce(ec_cart.adjustments, 0, fn x, acc ->
        adjustment_value(ec_cart, x) + acc
      end)

    subtotal + adjustments
  end

end
