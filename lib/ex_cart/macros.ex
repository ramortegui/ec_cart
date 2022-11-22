defmodule ExCart.Macros do
  defmodule Cart do
    defmacro __using__(opts) do
      quote do
        defstruct items: [], adjustments: []

        @max_items Application.get_env(:ex_cart, :max_items, 1000)

        def new, do: %ExCart.Cart{}

        def add_item(%ExCart.Cart{} = ex_cart, %ExCart.Item{} = cart_item) do
          %{ex_cart | items: insert_or_update_item(ex_cart.items, cart_item)}
        end

        defp insert_or_update_item(items, %ExCart.Item{sku: sku} = cart_item) do
          case item_in_cart(items, sku) do
            [] ->
              if Enum.count(items) < @max_items do
                items ++ [cart_item]
              else
                items
              end

            [_] ->
              update_items(items, cart_item)
          end
        end

        defp update_items(items, %ExCart.Item{sku: sku} = cart_item) do
          items =
            Enum.map(items, fn
              %ExCart.Item{sku: ^sku} = item ->
                %ExCart.Item{item | qty: item.qty + cart_item.qty}

              _ ->
                cart_item
            end)

          if Enum.count(items) > @max_items do
            Enum.pop(items)
          end
        end

        defp item_in_cart(items, sku) do
          Enum.filter(items, fn item -> item.sku == sku end)
        end

        def clear_items(cart) do
          %{cart | items: []}
        end

        def clear(cart) do
          cart = %{cart | items: []}
          %{cart | adjustments: []}
        end

        def add_adjustment(%ExCart.Cart{} = cart, %ExCart.Adjustment{} = adjustment) do
          %ExCart.Cart{cart | adjustments: cart.adjustments ++ [adjustment]}
        end

        def remove_adjustment(%ExCart.Cart{adjustments: adjustments} = cart, adj) do
          adjustments = Enum.reject(adjustments, &(&1.name == adj))
          %{cart | adjustments: adjustments}
        end

        def get_adjustment(
              %ExCart.Cart{adjustments: adjustments} = _cart,
              %ExCart.Adjustment{name: name} = _adjustment
            ) do
          adjustment = Enum.reject(adjustments, &(&1.name == name))
          {:ok, adjustment}
        end

        def get_adjustment_result(
              %ExCart.Cart{adjustments: adjustments} = cart,
              %ExCart.Adjustment{name: name} = _adjustment
            ) do
          adjustment = Enum.reject(adjustments, &(&1.name == name))
          adjustment_result = adjustment_result(cart, adjustment)
          {:ok, adjustment_result}
        end

        def clear_adjustments(%ExCart.Cart{adjustments: _adjustments} = cart) do
          %{cart | adjustments: []}
        end

        def subtotal(%ExCart.Cart{items: items}) do
          Enum.reduce(items, 0, fn x, acc -> x.qty * x.price + acc end)
        end

        defp adjustment_value(%ExCart.Cart{} = cart, %ExCart.Adjustment{} = adjustment) do
          adjustment.function.(cart)
        end

        defp adjustment_result(%ExCart.Cart{} = cart, adjustment) do
          subtotal = ExCart.Cart.subtotal(cart)

          adjustment_value = adjustment_value(cart, adjustment)

          adjustment = Map.put(adjustment, :adjustment_value, adjustment_value)

          {:ok, %{subtotal: subtotal, adjustment: adjustment}}
        end

        def total(%ExCart.Cart{} = cart) do
          subtotal = ExCart.Cart.subtotal(cart)

          adjustments =
            Enum.reduce(cart.adjustments, 0, fn x, acc ->
              adjustment_value(cart, x) + acc
            end)

          subtotal + adjustments
        end
      end
    end
  end

  defmodule Server do
    defmacro __using__(opts) do
      quote do
        use GenServer

        def init(_) do
          {:ok, ExCart.Cart.new()}
        end

        def start_link do
          GenServer.start_link(ExCart.Server, nil)
        end

        def handle_cast({:add_item, item}, state) do
          {:noreply, ExCart.Cart.add_item(state, item)}
        end

        def handle_cast({:clear_items}, state) do
          {:noreply, ExCart.Cart.clear_items(state)}
        end

        def handle_cast({:add_adjustment, adjustment}, state) do
          {:noreply, ExCart.Cart.add_adjustment(state, adjustment)}
        end

        def handle_cast({:remove_adjustment, adjustment}, state) do
          {:noreply, ExCart.Cart.remove_adjustment(state, adjustment)}
        end

        def handle_cast({:clear_adjustments}, state) do
          {:noreply, ExCart.Cart.clear_adjustments(state)}
        end

        def handle_call({:subtotal}, _, state) do
          {:reply, ExCart.Cart.subtotal(state), state}
        end

        def handle_call({:total}, _, state) do
          {:reply, ExCart.Cart.total(state), state}
        end

        def handle_call({:state}, _, state) do
          {:reply, state, state}
        end

        def add_item(pid, item) do
          GenServer.cast(pid, {:add_item, item})
        end

        def add_adjustment(pid, adjustment) do
          GenServer.cast(pid, {:add_adjustment, adjustment})
        end

        def remove_adjustment(pid, adjustment) do
          GenServer.cast(pid, {:remove_adjustment, adjustment})
        end

        def subtotal(pid) do
          GenServer.call(pid, {:subtotal})
        end

        def total(pid) do
          GenServer.call(pid, {:total})
        end

        def state(pid) do
          GenServer.call(pid, {:state})
        end

        def clear(pid) do
          GenServer.call(pid, {:clear})
        end

        def clear_items(pid) do
          GenServer.call(pid, {:clear_items})
        end

        def clear_adjustments(pid) do
          GenServer.call(pid, {:clear_adjustments})
        end
      end
    end
  end

  defmodule Item do
    defmacro __using__(opts) do
      quote do

      defstruct sku: nil, price: 0, qty: 1, attr: %{}

      def new(sku, price, qty, attr) do
        %ExCart.Item{sku: sku, price: price, qty: qty, attr: attr}
      end
    end
  end
  end

  defmodule Adjustment do
    defmacro __using__(opts) do
      quote do
        defstruct name: nil, description: nil, function: nil

        def new(name, description, function) do
          %ExCart.Adjustment{name: name, description: description, function: function}
        end
      end
    end
  end
end
