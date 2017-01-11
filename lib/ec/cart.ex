defmodule Ec.Cart do
  @moduledoc """
    Module to handle `Ec.Cart` structures.
  """
  defstruct items: [], adjustments: []

  @doc """
    Creates an empty %Ec.Cart{} structure, this strucure has by default 
    and empty list of items and and empty list of adjustments

    ##Example

        iex> Ec.Cart.new
        %Ec.Cart{adjustments: [], items: []}

  """
  def new, do: %Ec.Cart{}

  @doc """
    Add a new item into the %Ec.Cart{} structure, if the item already exists on the
    structure, this function will update the quantity.

    ## Example
    
        iex> ec_cart = Ec.Cart.new
        iex> Ec.Cart.add_item(ec_cart,%Ec.Cart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
        %Ec.Cart{adjustments: [],items: [%Ec.Cart.Item{attr: %{}, ec_price: 3, ec_qty: 10, ec_sku: "SU04"}]}

  """
  def add_item( %Ec.Cart{} = ec_cart, %Ec.Cart.Item{} = ec_cart_item ) do
    index = Enum.find_index( ec_cart.items, fn(item) -> item.ec_sku == ec_cart_item.ec_sku end )
    case index do
      nil ->
        case ec_cart_item.ec_qty do
          x when x > 0 -> %Ec.Cart{ adjustments: ec_cart.adjustments, items: ec_cart.items ++ [ec_cart_item] } 
          _ -> ec_cart
        end
      index ->
        item = Enum.at( ec_cart.items, index )
        item = %Ec.Cart.Item{ item | ec_qty: ( item.ec_qty + ec_cart_item.ec_qty ) }
        case item.ec_qty do
          x when x <= 0 -> %Ec.Cart{ adjustments: ec_cart.adjustments, items: List.delete_at(ec_cart.items, index ) }
          _ ->
            %Ec.Cart{ adjustments: ec_cart.adjustments, items: List.update_at(ec_cart.items, index,
              fn(old_item) -> %Ec.Cart.Item{ old_item | ec_qty: item.ec_qty } end )}
        end
    end
  end


  @doc """
    Add and adjutmens to the adjustment list.

    ## Example

    iex> ec_cart = Ec.Cart.new
    iex> adj = Ec.Cart.Adjustment.new(\"shipping\",\"Shipping\", 
    ...> fn(x) -> 
    ...> sb = Ec.Cart.subtotal(x)
    ...>  case sb do
    ...>    sb when sb > 25 -> 0
    ...>    _-> 10
    ...>   end
    iex> end)
    iex> ec_cart = Ec.Cart.add_adjustment(ec_cart,adj)
    iex> length ec_cart.adjustments
    1
  """
  def add_adjustment( %Ec.Cart{} =  ec_cart, %Ec.Cart.Adjustment{} = ec_cart_adjustment ) do
    %Ec.Cart{ec_cart | adjustments: ec_cart.adjustments++[ec_cart_adjustment] }
  end

  @doc """
    Calculate the sum of the result of multiply the price of each item and its quantity

    iex> ec_cart = Ec.Cart.new
    iex> ec_cart = Ec.Cart.add_item(ec_cart,%Ec.Cart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 2 })
    iex> Ec.Cart.subtotal(ec_cart)
    20

  """
  def subtotal( %Ec.Cart{ items: items} ) do
    Enum.reduce( items, 0, fn(x,acc) -> ( x.ec_qty * x.ec_price )+acc end)
  end

  defp adjustment_value(%Ec.Cart{} = ec_cart, %Ec.Cart.Adjustment{} = adjustment ) do
    adjustment.function.(ec_cart)
  end

  @doc """
    Calculates the total of the cart that include: subtotal + adjustments

    ## Example

    iex> ec_cart = Ec.Cart.new
    iex> ec_cart = Ec.Cart.add_item(ec_cart,%Ec.Cart.Item{ ec_sku: "SU04", ec_qty: 5, ec_price: 3 })
    iex> adj = Ec.Cart.Adjustment.new("shipping","Shipping", 
    ...> fn(x) -> 
    ...> sb = Ec.Cart.subtotal(x)
    ...>case sb do
    ...>  sb when sb > 25 -> 0
    ...>  _-> 10
    ...>end
    ...>end)
    iex> ec_cart = Ec.Cart.add_adjustment(ec_cart,adj)
    iex> Ec.Cart.total(ec_cart)
    25
  """
  def total( %Ec.Cart{} = ec_cart ) do
    subtotal = Ec.Cart.subtotal(ec_cart)
    adjustments = Enum.reduce(ec_cart.adjustments, 0, fn(x,acc) ->
      adjustment_value(ec_cart, x)+acc
    end)
    subtotal+adjustments
  end
end

