defmodule CalendricalTest.Helpers do
  def module_name(calendar) do
    String.capitalize(calendar)
  end

  def module(calendar) do
    Module.concat(Calendrical.Calendar, module_name(calendar))
  end

  def year(row, calendar) do
    fetch(row, calendar, "year")
  end

  def month(row, calendar) do
    fetch(row, calendar, "month")
  end

  def day(row, calendar) do
    fetch(row, calendar, "day")
  end

  def append(a, b) do
    a <> b
  end

  def fetch(row, calendar, item) do
    k = calendar
    |> append("_#{item}")
    |> String.to_atom

    Keyword.get(row, k)
  end

end
