# Ec.Cart

E-commerce cart for elixir

##Instalation

    - clone the repo
    - cd ec_cart
    - mix deps.get

## Run on iex

    iex -S mix

## Use as single app

    ec_cart = Ec.Cart.new
    ec_cart = Ec.Cart.add_item(ec_cart,%Ec.Cart.Item{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
    adj = Ec.Cart.Adjustment.new("shipping","Shipping", 
      fn(x) ->
      sb = Ec.Cart.subtotal(x)
        case sb do
          sb when sb > 25 -> 0
          _-> 10
        end
    end)
    ec_cart = Ec.Cart.add_adjustment(ec_cart,adj)
    Ec.Cart.total(ec_cart)


## Use as server (manage multiple cart processes and their states).

    {:ok, pid1} = Ec.Cart.Server.start_link
    Ec.Cart.Server.add_item(pid1,%Ec.Cart.Item{ ec_sku: "SU01", ec_qty: 10, ec_price: 3 })
    {:ok, pid2} = Ec.Cart.Server.start_link
    Ec.Cart.Server.add_item(pid2,%Ec.Cart.Item{ ec_sku: "SU02", ec_qty: 5, ec_price: 3 })
    adj = Ec.Cart.Adjustment.new("shipping","Shipping",
        fn(x) ->
            sb = Ec.Cart.subtotal(x)
                case sb do
                    sb when sb > 25 -> 0
                    _-> 10
                end
        end)
    Ec.Cart.Server.add_adjustment(pid1,adj)
    Ec.Cart.Server.add_adjustment(pid2,adj)
    Ec.Cart.Server.total(pid1)
    Ec.Cart.Server.total(pid2)

## How to use the cache to manage multiple EcCartServers

    {:ok, cache } = Ec.Cart.Cache.start_link
    cart_one = Ec.Cart.Cache.server_process("cart one")
    Ec.Cart.Server.add_item(cart_one,%Ec.Cart.Item{ec_sku: "SU01", ec_price: 10})
    Ec.Cart.Server.add_item(cart_one,%Ec.Cart.Item{ec_sku: "SU02", ec_price: 15})
    Ec.Cart.Server.subtotal(cart_one)
    cart_two = Ec.Cart.Cache.server_process("cart two")
    Ec.Cart.Server.add_item(cart_two,%Ec.Cart.Item{ec_sku: "SU01", ec_price: 2})
    Ec.Cart.Server.add_item(cart_two,%Ec.Cart.Item{ec_sku: "SU03", ec_price: 1})
    Ec.Cart.Server.subtotal(cart_two)

## How to use the supervisor as starting point.

    Ec.Cart.Supervisor.start_link
    cart_one = Ec.Cart.Cache.server_process("cart one")
    Ec.Cart.Server.add_item(cart_one,%Ec.Cart.Item{ec_sku: "SU01", ec_price: 10})
    Ec.Cart.Server.add_item(cart_one,%Ec.Cart.Item{ec_sku: "SU02", ec_price: 15})
    Ec.Cart.Server.subtotal(cart_one)
