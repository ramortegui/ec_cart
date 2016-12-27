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

    carts1 = EcCartServer.start
    EcCartServer.add_item(carts1,%EcCartItem{ ec_sku: "SU01", ec_qty: 10, ec_price: 3 })
    carts2 = EcCartServer.start
    EcCartServer.add_item(carts2,%EcCartItem{ ec_sku: "SU02", ec_qty: 5, ec_price: 3 })
    adj = EcCartAdjustment.new("shipping","Shipping", 
        fn(x) -> 
            sb = EcCart.subtotal(x)
                case sb do
                    sb when sb > 25 -> 0
                    _-> 10
                end 
        end)
    EcCartServer.add_adjustment(carts1,adj)

    EcCartServer.add_adjustment(carts2,adj)

    EcCartServer.total(carts1)

    EcCartServer.total(carts2)
