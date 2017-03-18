defmodule EcCart do
  @moduledoc """
    Module to handle `EcCart` structures.
  """
  defstruct items: [], adjustments: []

  @doc """
    Creates an empty %EcCart{} structure, this strucure has by default 
    and empty list of items and and empty list of adjustments

    ## Examples

        iex> EcCart.new
        %EcCart{adjustments: [], items: []}

  """
  def new, do: %EcCart{}

  @doc """
    Add a new item into the %EcCart{} structure, if the item already exists on the
    structure, this function will update the quantity.

    ## Examples
    
        iex> ec_cart = EcCart.new
        iex> EcCart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
        %EcCart{adjustments: [],items: [%EcCart.Item{attr: %{}, ec_price: 3, ec_qty: 10, ec_sku: "SU04"}]}

  """
  def add_item( %EcCart{} = ec_cart, %EcCart.Item{} = ec_cart_item ) do
    index = Enum.find_index( ec_cart.items, fn(item) -> item.ec_sku == ec_cart_item.ec_sku end )
    case index do
      nil ->
        case ec_cart_item.ec_qty do
          x when x > 0 -> %EcCart{ adjustments: ec_cart.adjustments, items: ec_cart.items ++ [ec_cart_item] } 
          _ -> ec_cart
        end
      index ->
        item = Enum.at( ec_cart.items, index )
        item = %EcCart.Item{ item | ec_qty: ( item.ec_qty + ec_cart_item.ec_qty ) }
        case item.ec_qty do
          x when x <= 0 -> %EcCart{ adjustments: ec_cart.adjustments, items: List.delete_at(ec_cart.items, index ) }
          _ ->
            %EcCart{ adjustments: ec_cart.adjustments, items: List.update_at(ec_cart.items, index,
              fn(old_item) -> %EcCart.Item{ old_item | ec_qty: item.ec_qty } end )}
        end
    end
  end


  @doc """
    Add and adjutmens to the adjustment list.

    ## Examples

        iex> ec_cart = EcCart.new
        iex> adj = EcCart.Adjustment.new(\"shipping\",\"Shipping\", 
        ...> fn(x) -> 
        ...> sb = EcCart.subtotal(x)
        ...>  case sb do
        ...>    sb when sb > 25 -> 0
        ...>    _-> 10
        ...>   end
        iex> end)
        iex> ec_cart = EcCart.add_adjustment(ec_cart,adj)
        iex> length ec_cart.adjustments
        1
  """
  def add_adjustment( %EcCart{} =  ec_cart, %EcCart.Adjustment{} = ec_cart_adjustment ) do
    %EcCart{ec_cart | adjustments: ec_cart.adjustments++[ec_cart_adjustment] }
  end

  @doc """
    Calculate the sum of the result of multiply the price of each item and its quantity
    
    ## Examples

        iex> ec_cart = EcCart.new
        iex> ec_cart = EcCart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 2 })
        iex> EcCart.subtotal(ec_cart)
        20

  """
  def subtotal( %EcCart{ items: items} ) do
    Enum.reduce( items, 0, fn(x,acc) -> ( x.ec_qty * x.ec_price )+acc end)
  end

  defp adjustment_value(%EcCart{} = ec_cart, %EcCart.Adjustment{} = adjustment ) do
    adjustment.function.(ec_cart)
  end

  @doc """
    Calculates the total of the cart that include: subtotal + adjustments

    ## Examples

      iex> ec_cart = EcCart.new
      iex> ec_cart = EcCart.add_item(ec_cart,%EcCart.Item{ ec_sku: "SU04", ec_qty: 5, ec_price: 3 })
      iex> adj = EcCart.Adjustment.new("shipping","Shipping", 
      ...> fn(x) -> 
      ...> sb = EcCart.subtotal(x)
      ...>case sb do
      ...>  sb when sb > 25 -> 0
      ...>  _-> 10
      ...>end
      ...>end)
      iex> ec_cart = EcCart.add_adjustment(ec_cart,adj)
      iex> EcCart.total(ec_cart)
      25
  """
  def total( %EcCart{} = ec_cart ) do
    subtotal = EcCart.subtotal(ec_cart)
    adjustments = Enum.reduce(ec_cart.adjustments, 0, fn(x,acc) ->
      adjustment_value(ec_cart, x)+acc
    end)
    subtotal+adjustments
  end
end

