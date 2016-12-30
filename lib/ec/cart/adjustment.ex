defmodule Ec.Cart.Adjustment do
  defstruct name: nil, description: nil, function: nil
  def new( name, description, function ) do
    %Ec.Cart.Adjustment{ name: name, description: description, function: function }
  end
end
