defmodule Calendrical do
  @moduledoc """
  Calendrical provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Rheingold.  This `rata die` gives a numberical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  Calendrical implements:

  * K-Day calculations in `Calendrical.Kday`

  * Additional Arithmetic calendar types (Julian calendar in the first release)

  * Astronomical calendar types (in a future release)
  """
  @days_in_a_week 7

  def days(:monday),    do: 1
  def days(:tuesday),   do: 2
  def days(:wednesday), do: 3
  def days(:thursday),  do: 4
  def days(:friday),    do: 5
  def days(:saturday),  do: 6
  def days(:sunday),    do: 7
  def days(day) when day in 1..@days_in_a_week, do: day

  @doc """
  Returns the day of the week as an integer between 1 (monday) and 7 (sunday)
  inclusive.

  ## Examples

    iex> Calendrical.day_of_week(~D[2017-01-01])
    7

    iex> Calendrical.day_of_week(~D[0001-01-01])
    1

    iex> Calendrical.day_of_week(~D[2017-06-30])
    5
  """
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
    mod = rem(day, @days_in_a_week)
    if mod == 0, do: 7, else: mod
  end

  def days_in_a_week do
    @days_in_a_week
  end

  @doc """
  Returns the number of days in `n` weeks

  ## Example

    iex> Calendrical.weeks(2)
    14
  """
  def weeks(n) do
    n * @days_in_a_week
  end

  @doc """
  Converts a `%Date{}` to a rata die
  """
  def date_to_rata_die(%Date{} = date) do
    date
    |> date_to_naive_datetime
    |> naive_datetime_to_rata_die
  end

  @doc """
  Converts a rata die to a `%Date{}`
  """
  def date_from_rata_die({_, {_, _}} = rata_die, calendar \\ Calendar.ISO) do
    {year, month, day, _, _, _, _} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, date} = Date.new(year, month, day)
    date
  end

  @doc """
  Converts a `%Date{}` to a `%NaiveDateTime{}`

  The time will be set to midnight.
  """
  def date_to_naive_datetime(%Date{year: year, month: month, day: day, calendar: calendar}) do
    {:ok, naive_datetime} = NaiveDateTime.new(year, month, day, 0, 0, 0, {0, 0}, calendar)
    naive_datetime
  end


  @doc """
  Converts a `%DateTime{}` to a rata die
  """
  def datetime_to_rata_die(%DateTime{} = date) do
    date
    |> datetime_to_naive_datetime
    |> naive_datetime_to_rata_die
  end

  @doc """
  Converts a rata die to a `%DateTime{}`

  The timezone is assumed to be "Etc/UTC".
  """
  def datetime_from_rata_die({_, {_, _}} = rata_die, calendar \\ Calendar.ISO) do
    {year, month, day, hour, minute, second, microsecond} = calendar.naive_datetime_from_rata_die(rata_die)
    {:ok, naive} = NaiveDateTime.new(year, month, day, hour, minute, second, microsecond)
    DateTime.from_naive!(naive, "Etc/UTC")
  end

  @doc """
  Converts a `%DateTime{}` to a `%NaiveDateTime{}`

  The timezone information is lost on coversion.  Since Elixir has no native
  support for timezones the convention of using "Etc/UTC" is used for the reverse
  conversion.
  """
  def datetime_to_naive_datetime(%DateTime{} = datetime) do
    DateTime.to_naive(datetime)
  end

  @doc """
  Converts a `%NaiveDateTime{}` to a rata die
  """
  def naive_datetime_to_rata_die(%NaiveDateTime{year: y, month: m, day: d, hour: h, minute: min,
        second: s, microsecond: ms, calendar: calendar}) do
    calendar.naive_datetime_to_rata_die(y, m, d, h, min, s, ms)
  end

  @doc """
  Converts a rata die to a `%NaiveDateTime{}`
  """
  def naive_datetime_from_rata_die({_, {_, _}} = rata_die, calendar) do
    calendar.naive_datetime_from_rata_die(rata_die)
  end
end

