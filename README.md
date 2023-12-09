# ExCart
E-commerce cart for elixir

[![Coverage Status](https://coveralls.io/repos/github/data-twister/ex_cart/badge.svg?branch=main)](https://coveralls.io/github/data-twister/ex_cart?branch=main)
![CircleCI](https://img.shields.io/circleci/build/github/data-twister/ex_cart)
[![Version](https://img.shields.io/hexpm/v/ex_cart.svg?style=flat-square)](https://hex.pm/packages/ex_cart)
![GitHub](https://img.shields.io/github/license/data-twister/ex_cart)
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/data-twister/ex_cart/main)


## Installation

    - clone the repo
    - cd ex_cart
    - mix deps.get

## Run on iex

    iex -S mix

## Use to store values 

    ex_cart = ExCart.Cart.new
    ex_cart = ExCart.Cart.add_item(ex_cart, %ExCart.Item{ec_sku: "SU04", ec_qty: 10, ec_price: 3})
    adj = ExCart.Adjustment.new("shipping","Shipping",
      fn(x) ->
      sb = ExCart.Cart.subtotal(x)
        case sb do
          sb when sb > 25 -> 0
          _-> 10
        end
    end)
    ex_cart = ExCart.Cart.add_adjustment(ex_cart,adj)
    ExCart.Cart.total(ex_cart)

## Use as server (manage multiple cart processes and their states).

    {:ok, pid1} = ExCart.Server.start_link
    ExCart.Server.add_item(pid1, %ExCart.Item{ec_sku: "SU01", ec_qty: 10, ec_price: 3})
    {:ok, pid2} = ExCart.Server.start_link
    ExCart.Server.add_item(pid2, %ExCart.Item{ec_sku: "SU02", ec_qty: 5, ec_price: 3})
    adj = ExCart.Adjustment.new("shipping","Shipping",
        fn(x) ->
            sb = ExCart.Cart.subtotal(x)
                case sb do
                    sb when sb > 25 -> 0
                    _-> 10
                end
        end)
    ExCart.Server.add_adjustment(pid1,adj)
    ExCart.Server.add_adjustment(pid2,adj)
    ExCart.Server.total(pid1)
    ExCart.Server.total(pid2)

## How to use the registry to manage multiple ExCartServers

    {:ok, session } = ExCart.Session.start_link
    cart_one = ExCart.Session.server_process("cart one")
    ExCart.Server.add_item(cart_one, %ExCart.Item{ec_sku: "SU01", ec_price: 10})
    ExCart.Server.add_item(cart_one, %ExCart.Item{ec_sku: "SU02", ec_price: 15})
    ExCart.Server.subtotal(cart_one)

    cart_two = ExCart.Session.server_process("cart two")
    ExCart.Server.add_item(cart_two, %ExCart.Item{ec_sku: "SU01", ec_price: 2})
    ExCart.Server.add_item(cart_two, %ExCart.Item{ec_sku: "SU03", ec_price: 1})
    ExCart.Server.subtotal(cart_two)

## How to use the Dynamic Supervised ExCartServers

    {:ok, pid } = ExCart.Cart.Supervisor.start_cart()
    ExCart.Server.state(pid)

## How to use the supervisor as starting point.

    ExCart.Supervisor.start_link
    cart_one = ExCart.Session.server_process("cart one")
    ExCart.Server.add_item(cart_one, %ExCart.Item{ec_sku: "SU01", ec_price: 10})
    ExCart.Server.add_item(cart_one, %ExCart.Item{ec_sku: "SU02", ec_price: 15})
    ExCart.Server.subtotal(cart_one)

### To use with Phoenix:
  - Add as dependency 
  - To see how it works, start the application on iex
  
      $ iex -S mix phoenix.server
      
      #And then start the observer.
      
      iex(n)>:observer.start
        
      #And you will see the ex_cart application aside of your app.

## Settings (config.exs)
  - config :ex_cart, max_items: 1000 

## License

Copyright 2022 Jason Clark
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
