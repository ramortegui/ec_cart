defmodule ExCart.Item do
  @moduledoc """
  Definition of the structure of an Item used by ExCart
  """
  defstruct ex_sku: nil, ex_price: 0, ex_qty: 1, attr: %{}

  @doc """
    Creates a structure based on: 

    `ex_sku` SKU of the item

    `ex_price` Float that represents the price of the item

    `ex_qty` Number that represents the quantity of the item 

    `attr` Aditional attributes that needs to be attached to the item, like description, name, etc.
  """
  def new(ex_sku, ex_price, ex_qty, attr) do
    %ExCart.Item{ex_sku: ex_sku, ex_price: ex_price, ex_qty: ex_qty, attr: attr}
  end
end
