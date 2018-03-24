# EcCart

E-commerce cart for elixir

## Instalation

    - clone the repo
    - cd ec_cart
    - mix deps.get

## Run on iex

    iex -S mix

## Use to store values 

    ec_cart = EcCart.Cart.new
    ec_cart = EcCart.Cart.add_item(ec_cart, %EcCart.Item{ec_sku: "SU04", ec_qty: 10, ec_price: 3})
    adj = EcCart.Adjustment.new("shipping","Shipping",
      fn(x) ->
      sb = EcCart.Cart.subtotal(x)
        case sb do
          sb when sb > 25 -> 0
          _-> 10
        end
    end)
    ec_cart = EcCart.Cart.add_adjustment(ec_cart,adj)
    EcCart.Cart.total(ec_cart)

## Use as server (manage multiple cart processes and their states).

    {:ok, pid1} = EcCart.Server.start_link
    EcCart.Server.add_item(pid1, %EcCart.Item{ec_sku: "SU01", ec_qty: 10, ec_price: 3})
    {:ok, pid2} = EcCart.Server.start_link
    EcCart.Server.add_item(pid2, %EcCart.Item{ec_sku: "SU02", ec_qty: 5, ec_price: 3})
    adj = EcCart.Adjustment.new("shipping","Shipping",
        fn(x) ->
            sb = EcCart.subtotal(x)
                case sb do
                    sb when sb > 25 -> 0
                    _-> 10
                end
        end)
    EcCart.Server.add_adjustment(pid1,adj)
    EcCart.Server.add_adjustment(pid2,adj)
    EcCart.Server.total(pid1)
    EcCart.Server.total(pid2)

## How to use the cache to manage multiple EcCartServers

    {:ok, cache } = EcCart.Cache.start_link
    cart_one = EcCart.Cache.server_process("cart one")
    EcCart.Server.add_item(cart_one, %EcCart.Item{ec_sku: "SU01", ec_price: 10})
    EcCart.Server.add_item(cart_one, %EcCart.Item{ec_sku: "SU02", ec_price: 15})
    EcCart.Server.subtotal(cart_one)
    cart_two = EcCart.Cache.server_process("cart two")
    EcCart.Server.add_item(cart_two, %EcCart.Item{ec_sku: "SU01", ec_price: 2})
    EcCart.Server.add_item(cart_two, %EcCart.Item{ec_sku: "SU03", ec_price: 1})
    EcCart.Server.subtotal(cart_two)

## How to use the supervisor as starting point.

    EcCart.Supervisor.start_link
    cart_one = EcCart.Cache.server_process("cart one")
    EcCart.Server.add_item(cart_one, %EcCart.Item{ec_sku: "SU01", ec_price: 10})
    EcCart.Server.add_item(cart_one, %EcCart.Item{ec_sku: "SU02", ec_price: 15})
    EcCart.Server.subtotal(cart_one)

### To use with Phoenix:
  - Add as dependency 
  - To see how it works, start the application on iex
  
      $ iex -S mix phoenix.server
      
      #And then start the observer.
      
      iex(n)>:observer.start
        
      #And you will see the ec_cart application aside of your app.

## TODO

  - Features to add:
    * Remove adjustments.
    * Get the result of and adjustment based on their name.
    * Cart summary.
    * Add Dynamic supervision for each cart instead one supervision for the
      cache

## License

Copyright 2018 Ruben Amortegui

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
