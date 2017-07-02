defmodule Calendrical.Calendar.Armenian do
  @behaviour Calendar
  alias Calendrical.RataDie
  alias Calendrical.Math

  @epoch {201_443, {1, 4}}
  def epoch do
    @epoch
  end

  @doc """
  Returns how many days there are in the given year-month.
  """
  def days_in_month(year, month)

  def days_in_month(_, month) when month in 1..12, do: 30
  def days_in_month(_, month) when month == 13, do: 5

  @doc """
  Returns true if the given year is a leap year.
  """
  def leap_year?(_year) do
    false
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

  Armenian days start at dawn.
  """
  def day_rollover_relative_to_midnight_utc() do
    {1, 4}
  end

  @doc """
  Returns `true` if the given date describes a proper date in the calendar.
  """
  def valid_date?(_year, month, day) when month in 1..12 and day in 1..30 do
    true
  end

  def valid_date?(_year, month, day) when month == 13 and day in 1..5 do
    true
  end

  def valid_date?(_year, _month, _day) do
    false
  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  @doc """
  Converts a `year`, `month` and `day` into a rata die number of days.
  """
  def date_to_rata_die_days(year, month, day) do
    epoch_days() + 365 * (year - 1) + 30 * (month - 1) + day - 1
  end

  @doc """
  Converts a rata die into a `%Date{}`
  """
  def date_from_rata_die_days(days) do
    days = days - epoch_days()
    year = trunc(Float.floor(days / 365) + 1)
    month = trunc(Float.floor(Math.mod(days, 365) / 30) + 1)
    day = days - 365 * (year - 1) - 30 * (month - 1) + 1
    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  {days, _time_fraction} = @epoch
  @days days
  defp epoch_days do
    @days
  end

  defp signature do
    " "<> "Armenian"
  end
end