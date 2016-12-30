# EcCart

E-commerce cart for elixir

##Instalation

    - clone the repo
    - cd ec_cart
    - mix deps.get

## Run on iex

    iex -S mix

## Use as single app

    ec_cart = EcCart.new
    ec_cart = EcCart.add_item(ec_cart,%EcCartItem{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })
    adj = EcCartAdjustment.new("shipping","Shipping", 
      fn(x) -> 
      sb = EcCart.subtotal(x)
        case sb do
          sb when sb > 25 -> 0
          _-> 10
        end 
    end)
    ec_cart = EcCart.add_adjustment(ec_cart,adj)
    EcCart.total(ec_cart)


## Use as server (manage multiple cart processes and their states).

    {:ok, pid1} = EcCartServer.start
    EcCartServer.add_item(pid1,%EcCartItem{ ec_sku: "SU01", ec_qty: 10, ec_price: 3 })
    {:ok, pid2} = EcCartServer.start
    EcCartServer.add_item(pid2,%EcCartItem{ ec_sku: "SU02", ec_qty: 5, ec_price: 3 })
    adj = EcCartAdjustment.new("shipping","Shipping", 
        fn(x) -> 
            sb = EcCart.subtotal(x)
                case sb do
                    sb when sb > 25 -> 0
                    _-> 10
                end 
        end)
    EcCartServer.add_adjustment(pid1,adj)

    EcCartServer.add_adjustment(pid2,adj)

    EcCartServer.total(pid1)

    EcCartServer.total(pid2)
