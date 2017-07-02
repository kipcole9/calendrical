defmodule Calendrical.Calendar.Gregorian do
  @behaviour Calendar
  alias Calendrical.RataDie
  alias Calendrical.Math

  def gregorian_epoch do
    {1, {0, 1}}
  end

  @doc """
  Returns how many days there are in the given year-month.

  This is the same as `Calendar.ISO` except that negative
  years are acceptable.
  """
  def days_in_month(year, month)

  def days_in_month(year, 2) do
    if leap_year?(year), do: 29, else: 28
  end
  def days_in_month(_, month) when month in [4, 6, 9, 11], do: 30
  def days_in_month(_, month) when month in 1..12, do: 31

  @doc """
  Returns true if the given year is a leap year.
  A leap year is a year of a longer length than normal. The exact meaning
  is up to the calendar. A calendar must return `false` if it does not support
  the concept of leap years.
  """
  def leap_year?(year) when is_integer(year) do
    Math.mod(year, 4) === 0 and (Math.mod(year, 100) > 0 or Math.mod(year, 400) === 0)
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
    Calendar.ISO.date_to_string(year, month, day)
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    Calendar.ISO.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond)
  end

  @doc """
  Converts the datetime (with time zone) into a string according to the calendar.
  """
  def datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset) do
    Calendar.ISO.datetime_to_string(year, month, day, hour, minute, second, microsecond,
                               time_zone, zone_abbr, utc_offset, std_offset)
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
  Define the rollover moment for the given calendar.
  This is the moment, in your calendar, when the current day ends
  and the next day starts.
  The result of this function is used to check if two calendars rollover at
  the same time of day. If they do not, we can only convert datetimes and times
  between them. If they do, this means that we can also convert dates as well
  as naive datetimes between them.
  This day fraction should be in its most simplified form possible, to make comparisons fast.
  ## Examples
    * If, in your Calendar, a new day starts at midnight, return {0, 1}.
    * If, in your Calendar, a new day starts at sunrise, return {1, 4}.
    * If, in your Calendar, a new day starts at noon, return {1, 2}.
    * If, in your Calendar, a new day starts at sunset, return {3, 4}.
  """
  def day_rollover_relative_to_midnight_utc() do
    {0, 1}
  end

  @doc """
  Should return `true` if the given date describes a proper date in the calendar.
  """
  def valid_date?(year, month, day) do
    (month in 1..12) and (day <= days_in_month(year, month)) and year <= 10_000
  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  def date_to_rata_die_days(year, month, day) do
    correction =
      cond do
        month <= 2 -> 0
        leap_year?(year) -> -1
        true ->  -2
      end

    (gregorian_epoch_days() - 1) +
    (365 * (year - 1)) +
    Float.floor((year - 1) / 4) -
    Float.floor((year - 1) / 100) +
    Float.floor((year - 1) / 400) +
    Float.floor((367 * month - 362) / 12) +
    correction + day |> trunc
  end

  def date_from_rata_die_days(gregorian_days) do
    year = year_from_gregorian_days(gregorian_days)

    correction =
      cond do
        gregorian_days < date_to_rata_die_days(year, 3, 1) -> 0
        leap_year?(year) -> 1
        true -> 2
      end

    prior_days  = gregorian_days - date_to_rata_die_days(year, 1, 1)

    month = Float.floor(((12 * (prior_days + correction)) + 373) / 367) |> trunc
    day = 1 + gregorian_days - date_to_rata_die_days(year, month, 1)
    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  def year_from_gregorian_days(gregorian_days) do
    d0 = gregorian_days - gregorian_epoch_days()
    {n400, d1} = Math.div_mod(d0, 146_097)
    {n100, d2} = Math.div_mod(d1, 36_524)
    {n4, d3}   = Math.div_mod(d2, 1_461)
    n1         = Float.floor(d3 / 365)
    year = trunc((400 * n400) + (100 * n100) + (4 * n4) + n1)
    if ((n100 == 4) || (n1 == 4)), do: year, else: year + 1
  end

  defp gregorian_epoch_days do
    1
  end
end