# EcCart

E-commerce cart for elixir

## Use

ec_cart = EcCart.new

ec_cart = EcCart.add_item(ec_cart,%EcCartItem{ ec_sku: "SU04", ec_qty: 10, ec_price: 3 })

adj = EcCartAdjustment.new("shipping","Shipping", 
  fn(x) -> 
    sb = EcCart.subtotal(x)
    case sb do 
     sb when sb > 25 -> 0
     _-> 10;  
    end 
  end)

ec_cart = EcCart.add_adjustment(ec_cart,adj)


EcCart.total(ec_cart)
