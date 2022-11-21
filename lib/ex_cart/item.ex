defmodule ExCart.Item do
  @moduledoc """
  Definition of the structure of an Item used by ExCart
  """
  defstruct sku: nil, price: 0, qty: 1, attr: %{}

  @doc """
    Creates a structure based on: 

    `sku` SKU of the item

    `price` Float that represents the price of the item

    `qty` Number that represents the quantity of the item

    `attr` Additional attributes that needs to be attached to the item, like description, name, etc.
  """
  def new(sku, price, qty, attr) do
    %ExCart.Item{sku: sku, price: price, qty: qty, attr: attr}
  end
end
