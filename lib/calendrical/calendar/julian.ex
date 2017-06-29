defmodule Calendrical.Calendar.Julian do
  @behaviour Calendar
  alias Calendrical.RataDie
  import Calendrical.Math

  {:ok, epoch_date} = Date.new(0, 12, 30, Calendar.ISO)
  @julian_epoch Calendrical.date_to_rata_die(epoch_date)
  def julian_epoch do
    @julian_epoch
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
    mod(year, 4) == 0
  end

  def leap_year?(year) do
    mod(year, 4) == 3
  end

  @doc """
  Calculates the day of the week from the given `year`, `month`, and `day`.
  """
  def day_of_week(year, month, day) do
    {:ok, date} = Date.new(year, month, day, __MODULE__)

    date
    |> Calendrical.date_to_rata_die
    |> RataDie.day_of_week
  end

  @doc """
  Converts the date into a string according to the calendar.
  """
  def date_to_string(year, month, day) do
    Calendar.ISO.date_to_string(year, month, day) <> julian_signature()
  end

  @doc """
  Converts the datetime (without time zone) into a string according to the calendar.
  """
  def naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) do
    Calendar.ISO.naive_datetime_to_string(year, month, day, hour, minute, second, microsecond) <>
    julian_signature()
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
    {year, month, day} = date_from_rata_die_days(days)
    {hour, minute, second, microsecond} = time_from_day_fraction(day_fraction)
    {year, month, day, hour, minute, second, microsecond}
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

  end

  @doc """
  Should return `true` if the given time describes a proper time in the calendar.
  """
  def valid_time?(hour, minute, second, microsecond) do
    Calendar.ISO.valid_time?(hour, minute, second, microsecond)
  end

  defp julian_signature do
    "JUL"
  end

  def date_to_rata_die_days(year, month, day) do
    {julian_epoch_days, _} = julian_epoch()
    y =
      if year < 0 do
        year + 1
      else
        year
      end
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
    (julian_epoch_days - 1) + (365 * (y - 1)) + Float.floor((y - 1) / 4) +

    # plus number of days in the prior months in the current year plus
    # the corresponding number of leap days
    (1 / 12) * (367 * month - 362) + correction +

    # and lastly the number of days since the start of the
    # current month
    day |> trunc
  end

  def date_from_rata_die_days({days, time_fraction}) do
    {julian_epoch_day, _} = julian_epoch()
    approx = trunc(1 / 1461 * (4 * (days - julian_epoch_days)))

    year =
      if approx <= 0 do
        approx - 1
      else
        approx
      end

    correction =
      cond do
        date < fixed_from_julian(year, march, 1) -> 0
        leap_year?(year) -> 1
        true -> 2
      end

    prior_days = date - fixed_from_julian(year, jan, 1)

    month = trunc(Float.floor(1 / 367 * (12 * (prior_days + correction) + 373)))
    day = trunc(date - fixed_from_julian(year, month, 1) + 1)
    Date.new(year, month, day, __MODULE__)
  end
end