defmodule EcCartItem do
  defstruct ec_sku: nil, ec_price: 0, ec_qty: 1, attr: %{}
  def new( ec_sku, ec_price, ec_qty, attr) do
    %EcCartItem{ ec_sku: ec_sku, ec_price: ec_price, ec_qty: ec_qty, attr: attr }
  end
end
