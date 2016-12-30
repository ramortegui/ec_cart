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

    {:ok, pid1} = Ec.Cart.Server.start
    Ec.Cart.Server.add_item(pid1,%Ec.Cart.Item{ ec_sku: "SU01", ec_qty: 10, ec_price: 3 })
    {:ok, pid2} = Ec.Cart.Server.start
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
