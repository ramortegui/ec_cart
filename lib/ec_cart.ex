
defmodule EcCartItem do
  defstruct ec_sku: nil, ec_price: 0, ec_qty: 1, attr: %{}
  def new( ec_sku, ec_price, ec_qty, attr) do
    %EcCartItem{ ec_sku: ec_sku, ec_price: ec_price, ec_qty: ec_qty, attr: attr }
  end
end

defmodule EcCart do
  defstruct items: []
  def new, do: %EcCart{}
  def addItem( %EcCart{ items: items }, %EcCartItem{} = ec_cart_item ) do
    index = Enum.find_index( items, fn(item) -> item.ec_sku == ec_cart_item.ec_sku end )
    case index do
      nil ->
        %EcCart{
          items: items++[ec_cart_item]
        }
      x ->
        item = Enum.at( items, x )
        item = %EcCartItem{ item | ec_qty: ( item.ec_qty + ec_cart_item.ec_qty ) }
        %EcCart{ items: List.update_at(items, x, fn(old_item) -> %EcCartItem{ old_item | ec_qty: item.ec_qty } end )}
    end
  end
end

