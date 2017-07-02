defmodule Calendrical.Calendar.Coptic do
  @behaviour Calendar
  alias Calendrical.RataDie
  alias Calendrical.Math

  {:ok, epoch_date} = Date.new(284, 8, 29, Calendrical.Calendar.Julian)
  @epoch Calendrical.rata_die_from_date(epoch_date)
  def epoch do
    @epoch
  end

  @doc """
  Returns how many days there are in the given year-month.
  """
  def days_in_month(year, month)

  def days_in_month(year, 2) do
    if leap_year?(year), do: 29, else: 28
  end
  def days_in_month(_, month) when month in [4, 6, 9, 11], do: 30
  def days_in_month(_, month) when month in 1..12, do: 31

  @doc """
  Returns true if the given year is a leap year.
  """
  def leap_year?(year) do
    Math.mod(year, 4) == 3
  end

  @doc """
  Calculates the day of the week from the given `year`, `month`, and `day`.
  """
  def day_of_week(year, month, day) do
    {:ok, date} = Date.new(year, month, day, __MODULE__)

    date
    |> Calendrical.rata_die_from_date
    |> RataDie.day_of_week
  end

  @doc """
  Converts the date into a string according to the calendar.
  """
  def date_to_string(year, month, day) do
    Calendar.ISO.date_to_string(year, month, day) <> signature()
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    Calendar.ISO.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) <>
    signature()
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  def datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset) do
    Calendar.ISO.datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset) <> signature()
  end

  @doc """
  Converts the time into a string according to the calendar.
  """
  def time_to_string(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_string(hour, minute, second, microsecond)
  end

  @doc """
  Converts the given datetime (with time zone) into the `t:rata_die` format.
  """
  def naive_datetime_to_rata_die(year, month, day, hour, minute, second, microsecond) do
    {date_to_rata_die_days(year, month, day),
     time_to_day_fraction(hour, minute, second, microsecond)}
  end

  @doc """
  Converts `t:rata_die` to the Calendar's datetime format.
  """
  def naive_datetime_from_rata_die({days, day_fraction}) do
    date = date_from_rata_die_days(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {date.year, date.month, date.day, hour, minute, second, microsecond}
  end

  @doc """
  Converts the given time to the `t:day_fraction` format.
  """
  def time_to_day_fraction(hour, minute, second, microsecond) do
    Calendar.ISO.time_to_day_fraction(hour, minute, second, microsecond)
  end

  @doc """
  Converts `t:day_fraction` to the Calendar's time format.
  """
  def time_from_day_fraction(day_fraction) do
    Calendar.ISO.time_from_day_fraction(day_fraction)
  end

  @doc """
  Define the rollover moment for the Coptic calendar.

  Coptic days start at sunset.
  """
  def day_rollover_relative_to_midnight_utc() do
    {3, 4}
  end

  @doc """
  Should return `true` if the given date describes a proper date in the calendar.
  """
  def valid_date?(_year, month, day) when month in 1..12 and day in 1..30 do
    true
  end

  def valid_date?(year, month, day) when month == 13 do
    cond do
      leap_year?(year) and day in 1..6 -> true
      day in 1..5 -> true
      true -> false
    end
  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  def date_to_rata_die_days(%Date{calendar: __MODULE__, year: year, month: month, day: day}) do
    date_to_rata_die_days(year, month, day)
  end

  @doc """
  Converts a `year`, `month` and `day` into a rata die number of days.
  """
  def date_to_rata_die_days(year, month, day) do
    epoch_days() - 1 + (365 * (year - 1)) + Float.floor((year / 4) +
    30 * (month - 1)) + day |> trunc
  end

  @doc """
  Converts a rata die into a `%Date{}`
  """
  def date_from_rata_die_days(days) do
    year = Float.floor((4 * (days - epoch_days()) + 1463) / 1461) |> trunc
    month =
      1 +
      Float.floor((days - date_to_rata_die_days(year, 1, 1)) / 30) |> trunc
    day = days + 1 - date_to_rata_die_days(year, month, 1) |> trunc
    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  {days, _time_fraction} = @epoch
  @days days
  defp epoch_days do
    @days
  end

  defp signature do
    " "<> "Coptic"
  end
end