defmodule EcCartAdjustment do
  defstruct name: nil, description: nil, function: nil
  def new( name, description, function ) do
    %EcCartAdjustment{ name: name, description: description, function: function }
  end
end
