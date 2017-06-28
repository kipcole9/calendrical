defmodule Calendrical do
  @days_in_a_week 7

  def days(:monday),    do: 1
  def days(:tuesday),   do: 2
  def days(:wednesday), do: 3
  def days(:thursday),  do: 4
  def days(:friday),    do: 5
  def days(:saturday),  do: 6
  def days(:sunday),    do: 7
  def days(day) when is_integer(day) and day in 1..@days_in_a_week, do: day

  def day_of_week(%Date{} = date) do
    date
    |> date_to_naive_datetime
    |> day_of_week
  end

  def day_of_week(%NaiveDateTime{} = datetime) do
    datetime
    |> naive_datetime_to_rata_die
    |> day_of_week
  end

  def day_of_week({day, {_, _}}) do
    rem(day, @days_in_a_week)
  end

  def days_in_a_week do
    @days_in_a_week
  end

  def weeks(n) do
    n * @days_in_a_week
  end

  def date_to_rata_die(%Date{} = date) do
    date
    |> date_to_naive_datetime
    |> naive_datetime_to_rata_die
  end

  def datetime_to_rata_die(%DateTime{} = date) do
    date
    |> datetime_to_naive_datetime
    |> naive_datetime_to_rata_die
  end

  def date_to_naive_datetime(%Date{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 0}, calendar)
    naive_datetime
  end

  def datetime_to_naive_datetime(%DateTime{} = datetime) do
    DateTime.to_naive(datetime)
  end

  def naive_datetime_to_rata_die(%NaiveDateTime{year: y, month: m, day: d, hour: h, minute: min,
        second: s, microsecond: ms, calendar: calendar}) do
    calendar.naive_datetime_to_rata_die(y, m, d, h, min, s, ms)
  end

  def naive_datetime_from_rata_die({_, {_, _}} = rata_die, calendar) do
    calendar.naive_datetime_from_rata_die(rata_die)
  end

  def date_from_rata_die({_, {_, _}} = rata_die, calendar) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  def datetime_from_rata_die({_, {_, _}} = rata_die, calendar) do
    {year, month, day, hour, minute, second, microsecond} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, naive} = NaiveDateTime.new(year, month, day, hour, minute, second, microsecond, calendar)
    DateTime.from_naive!(naive, "Etc/UTC")
  end
end

