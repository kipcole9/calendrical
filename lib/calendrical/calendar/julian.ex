defmodule Calendrical.Calendar.Julian do
  @behaviour Calendar
  alias Calendrical.RataDie
  alias Calendrical.Math

  {:ok, epoch_date} = Date.new(0, 12, 30, Calendar.ISO)
  @epoch Calendrical.rata_die_from_date(epoch_date)
  def epoch do
    @epoch
  end

  @doc """
  Returns how many days there are in the given year-month.

  This is the same as `Calendar.ISO` except that the leap_year
  calculation is different.
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
  def leap_year?(year) when year > 0 do
    Math.mod(year, 4) == 0
  end

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
    signature() <> signature()
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

  @doc """
  Converts a `year`, `month` and `day` into a rata die number of days.
  """
  def date_to_rata_die_days(year, month, day) do
    y =
      if year < 0 do
        year + 1
      else
        year
      end

    correction =
      cond do
        month <= 2 -> 0
        leap_year?(year) -> -1
        true -> -2
      end

    # Number of non-leap days from the day before the start of the
    # Julian epoch and the last day before the start of the current
    # year
    epoch_days() - 1 + (365 * (y - 1)) + Float.floor((y - 1) / 4) +

    # plus number of days in the prior months in the current year plus
    # the corresponding number of leap days
    Float.floor((367 * month - 362) / 12) + correction +

    # and lastly the number of days since the start of the
    # current month
    day |> trunc
  end

  @doc """
  Converts a rata die into a `%Date{}`
  """
  def date_from_rata_die_days(julian_days) do
    approx = Float.floor(((4 * (julian_days - epoch_days())) + 1464) / 1461) |> trunc

    year =
      if approx <= 0 do
        approx - 1
      else
        approx
      end

    correction =
      cond do
        julian_days < date_to_rata_die_days(year, 3, 1) -> 0
        leap_year?(year) -> 1
        true -> 2
      end

    prior_days = julian_days - date_to_rata_die_days(year, 1, 1)

    month = Float.floor((12 * (prior_days + correction) + 373) / 367) |> trunc
    day = julian_days - date_to_rata_die_days(year, month, 1) + 1
    {:ok, date} = Date.new(year, month, day, __MODULE__)
    date
  end

  {days, _time_fraction} = @epoch
  @days days
  defp epoch_days do
    @days
  end

  defp signature do
    " " <> "Julian "
  end
end