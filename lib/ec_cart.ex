
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
        case ec_cart_item.ec_qty do
          x when x > 0 -> %EcCart{ items: items++[ec_cart_item] } 
          _ -> %EcCart{ items: items }
        end
      index ->
        item = Enum.at( items, index )
        item = %EcCartItem{ item | ec_qty: ( item.ec_qty + ec_cart_item.ec_qty ) }
        case item.ec_qty do
          x when x <= 0 -> %EcCart{ items: List.delete_at(items, index ) }
          _ ->
            %EcCart{ items: List.update_at(items, index,
              fn(old_item) -> %EcCartItem{ old_item | ec_qty: item.ec_qty } end )}
        end
    end
  end
end

