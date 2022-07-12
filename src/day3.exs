# Part 1
File.stream!("input/day3")
|> Enum.map(fn bytes -> for b <- String.to_charlist(String.trim(bytes)), do: b - 48 end)
|> then(fn list -> {
  Enum.count(list) / 2,
  Enum.reduce(list, fn bytes, memo -> for {a,b} <- Enum.zip(bytes, memo), do: a+b end)
} end)
|> then(fn {half, list} -> Enum.map(list, fn
    bit when bit > half -> {1,0}
    _bit -> {0,1}
  end)
end)
|> Enum.unzip
|> then(fn {gamma, epsilon} ->
  String.to_integer(Enum.join(gamma), 2) * String.to_integer(Enum.join(epsilon), 2)
end)

# Part 2
defmodule Partition do
  defstruct a: [], a_count: 0, b: [], b_count: 0
  def partition(list, func, result \\ %Partition{})
  def partition([], _func, result), do: result
  def partition([head|tail], func, result) do
    case func.(head) do
    true -> partition(tail, func, %{result | a: [head | result.a], a_count: result.a_count + 1})
    false -> partition(tail, func, %{result | b: [head | result.b], b_count: result.b_count + 1})
    end
  end
end

defmodule LifeSupport do
  def popular_bytes(list, default, nth \\ 0)
  def popular_bytes([head|tail], _default, nth) when byte_size(head) == nth, do: [head|tail]
  def popular_bytes(list, default, nth) do
    result = Partition.partition(list, filter_nth_byte_fn(nth, default))
    winner = if result.b_count > result.a_count, do: result.b, else: result.a
    popular_bytes(winner, default, nth+1)
  end
  def unpopular_bytes(list, default, nth \\ 0)
  def unpopular_bytes([head|tail], _default, nth) when byte_size(head) == nth, do: [head|tail]
  def unpopular_bytes(list, default, nth) do
    result = Partition.partition(list, filter_nth_byte_fn(nth, default))
    winner = case {result.a_count, result.b_count} do
      {0, _} -> result.b
      {_, 0} -> result.a
      {a, b} when b < a -> result.b
      _ -> result.a
    end
    unpopular_bytes(winner, default, nth+1)
  end
  def filter_nth_byte_fn(nth, default)
    fn <<_skip::binary-size(nth), byte::binary-size(1), _rest::binary>> -> byte == default end
  end
end

File.stream!("input/day3")
|> Enum.map(&String.trim/1)
|> then(fn list -> {
  LifeSupport.popular_bytes(list, "1")|>hd|>String.to_integer(2),
  LifeSupport.unpopular_bytes(list, "0")|>hd|>String.to_integer(2)
} end)
|> then(fn {oxygen,co2} -> oxygen * co2 end)