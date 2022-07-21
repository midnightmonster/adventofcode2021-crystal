defmodule Polymer do
  defstruct template: %{}, rules: %{}, left: nil
  def parse_template(str, poly \\ %Polymer{})
  def parse_template(<<a::binary-size(1), b::binary-size(1), rest::binary>>, poly) do
    parse_template(b <> rest, %{poly | left: poly.left || a, template: Map.update(poly.template, a<>b, 1, &(&1 + 1))})
  end
  def parse_template(_, poly), do: poly
  def add_rule([pair,insert], poly \\ %Polymer{}) do
    <<left::binary-size(1), right::binary-size(1)>> = pair
    %{poly | rules: Map.put(poly.rules, pair, [left <> insert, insert <> right])}
  end
  def apply_rules(poly) do
    poly.template
    |> Enum.flat_map(fn {pair, count} -> Enum.map(poly.rules[pair], &({&1, count})) end)
    |> Enum.reduce(%{}, fn {pair, count}, memo -> Map.update(memo, pair, count, &(&1 + count)) end)
    |> then(fn t -> %{poly | template: t} end)
  end
  def parse_line(line, poly) do
    case Regex.run(~r/^(\w+)(?: -> (\w))?$/, line) do
      [_, pair, insert] -> add_rule([pair, insert], poly)
      [_, template] -> parse_template(template, poly)
      _ -> poly
    end
  end
  def element_counts(poly) do
    Enum.reduce(poly.template, %{poly.left => 1}, fn {<<_::binary-size(1), r::binary-size(1)>>, count}, memo ->
      Map.merge(memo, %{r => count}, fn _, a, b -> a + b end)
    end)
  end
end

element_spread = fn poly -> tap(poly, fn p ->
  {min, max} = p |> Polymer.element_counts |> Map.values |> Enum.min_max
  IO.puts(max - min)
end) end

poly = File.stream!("input/day14") |> Enum.reduce(%Polymer{}, &Polymer.parse_line/2)
poly = 1..10 |> Enum.reduce(poly, fn _, poly -> Polymer.apply_rules(poly) end)
|> element_spread.()
1..30 |> Enum.reduce(poly, fn _, poly -> Polymer.apply_rules(poly) end)
|> element_spread.()
