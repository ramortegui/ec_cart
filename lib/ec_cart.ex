
defmodule EcCartItem do
  defstruct ec_sku: nil, ec_price: 0, ec_quantity: 1, attr: %{}
  def new( ec_sku, ec_price, ec_quantity, attr) do
    %EcCartItem{ ec_sku: ec_sku, ec_price: ec_price, ec_quantity: ec_quantity, attr: attr }
  end
end

defmodule EcCart do
  defstruct items: []
  def new, do: %EcCart{}
  def addItem( %EcCart{ items: items }, %EcCartItem{} = ec_cart_item ) do
    %EcCart{
      items: items++[ec_cart_item]
    }
  end
end

