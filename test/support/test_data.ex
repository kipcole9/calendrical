defmodule CalendricalTest.Data do
  def file(n) when n in 1..5 do
    "./test/data/dates#{n}.csv"
    |> File.stream!
    |> CSV.decode!(headers: true, strip_fields: true)
    |> Enum.map(&(transform(n, &1)))
  end

  def transform(1, row) do
    Enum.map row, fn
      {"j_day" = k, v} -> {String.to_atom(k), String.to_float(v)}
      {"r5" = k, v} -> {String.to_atom(k), v}
      {"weekday" = k, v} -> {String.to_atom(k), String.downcase(v) |> String.to_atom}
      {k, v} -> {String.to_atom(k), String.to_integer(v)}
    end
  end

  def transform(2, row) do
    Enum.map row, fn
      {k, v} -> {String.to_atom(k), String.to_integer(v)}
    end
  end
end


