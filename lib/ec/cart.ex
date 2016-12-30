defmodule Ec.Cart do
  defstruct items: [], adjustments: []
  def new, do: %Ec.Cart{}
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

  def add_adjustment( %Ec.Cart{} =  ec_cart, %Ec.Cart.Adjustment{} = ec_cart_adjustment ) do
    %Ec.Cart{ec_cart | adjustments: ec_cart.adjustments++[ec_cart_adjustment] }
  end

  def subtotal( %Ec.Cart{ items: items} ) do
    Enum.reduce( items, 0, fn(x,acc) -> ( x.ec_qty * x.ec_price )+acc end)
  end

  def adjustment_value(%Ec.Cart{} = ec_cart, %Ec.Cart.Adjustment{} = adjustment ) do
    adjustment.function.(ec_cart)
  end

  def total( %Ec.Cart{} = ec_cart ) do
    subtotal = Ec.Cart.subtotal(ec_cart)
    adjustments = Enum.reduce(ec_cart.adjustments, 0, fn(x,acc) ->
      adjustment_value(ec_cart, x)+acc
    end)
    subtotal+adjustments
  end

end

