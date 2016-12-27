defmodule EcCartServer do

  #interface functions
  def start do
    spawn(fn -> loop(EcCart.new) end)
  end
 
  def value(ec_cart_server) do
    send(ec_cart_server, {:value, self })
    receive do
      {:ec_cart, value} -> value
     after 5000 -> {:error, :timeout}
    end
  end

  def add_item(ec_cart_server, value) do
    send(ec_cart_server,{:add_item,value})
  end

  def add_adjustment(ec_cart_server, value) do
    send(ec_cart_server,{:add_adjustment,value})
  end

  def subtotal(ec_cart_server) do
    send(ec_cart_server, {:subtotal, self })
    receive do
      {:response, value} -> value
     after 5000 -> {:error, :timeout}
    end
  end

  def total(ec_cart_server) do
    send(ec_cart_server, {:total, self })
    receive do
      {:response, value} -> value
     after 5000 -> {:error, :timeout}
    end
  end

  #Implementation funcitons
  defp loop(ec_cart) do
    new_ec_cart = receive do
      message -> process_message(ec_cart, message)
    end
    loop(new_ec_cart)
  end

  defp process_message(ec_cart, {:value, caller} ) do
    send( caller, { :ec_cart, ec_cart } )
    ec_cart
  end

  defp process_message(ec_cart, {:add_item, new_item} ) do
    EcCart.add_item(ec_cart, new_item)
  end 

  defp process_message(ec_cart, {:add_adjustment, new_adjustment} ) do
    EcCart.add_adjustment(ec_cart, new_adjustment)
  end 

  defp process_message(ec_cart, {:subtotal, caller}) do
    send(caller, {:response, EcCart.subtotal(ec_cart)})
    ec_cart
  end

  defp process_message(ec_cart, {:total, caller}) do
    send(caller, {:response, EcCart.total(ec_cart)})
    ec_cart
  end

end
defmodule EcCart do
  defstruct items: [], adjustments: []
  def new, do: %EcCart{}
  def add_item( %EcCart{ items: items }, %EcCartItem{} = ec_cart_item ) do
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

  def add_adjustment( %EcCart{} =  ec_cart, %EcCartAdjustment{} = ec_cart_adjustment ) do
    %EcCart{ec_cart | adjustments: ec_cart.adjustments++[ec_cart_adjustment] }
  end

  def subtotal( %EcCart{ items: items} ) do
    Enum.reduce( items, 0, fn(x,acc) -> ( x.ec_qty * x.ec_price )+acc end)
  end

  def adjustment_value(%EcCart{} = ec_cart, %EcCartAdjustment{} = adjustment ) do
    adjustment.function.(ec_cart)
  end

  def total( %EcCart{} = ec_cart ) do
    subtotal = EcCart.subtotal(ec_cart)
    adjustments = Enum.reduce(ec_cart.adjustments, 0, fn(x,acc) ->
      adjustment_value(ec_cart, x)+acc
    end)
    subtotal+adjustments
  end

end

