defmodule EcCart.Item do
  @moduledoc """
  Definition of the structure of an Item used by EcCart
  """
  defstruct ec_sku: nil, ec_price: 0, ec_qty: 1, attr: %{}

  @doc """
    Creates a structure based on: 

    `ec_sku` SKU of the item

    `ec_price` Float that represents the price of the item

    `ec_qty` Number that represents the quantity of the item 

    `attr` Aditional attributes that needs to be attached to the item, like description, name, etc.
  """
  def new(ec_sku, ec_price, ec_qty, attr) do
    %EcCart.Item{ec_sku: ec_sku, ec_price: ec_price, ec_qty: ec_qty, attr: attr}
  end
end
