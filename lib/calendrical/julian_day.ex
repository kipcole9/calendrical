defmodule Calendrical.JulianDay do
  @moduledoc """
  Converts `%Date{}` to and from  Julian Day (which is not the same thing as
  a day in the Julian Calendar).

  The Julian Day Count is a uniform count of days from a remote epoch in the
  past (-4712 January 1, 12 hours Greenwich Mean Time (Julian proleptic
  Calendar) = 4713 BCE January 1, 12 hours GMT (Julian proleptic Calendar) =
  4714 BCE November 24, 12 hours GMT (Gregorian proleptic Calendar)). At this
  instant, the Julian Day Number is 0. It is convenient for astronomers to use
  since it is not necessary to worry about odd numbers of days in a month, leap
  years, etc. Once you have the Julian Day Number of a particular date in
  history, it is easy to calculate time elapsed between it and any other Julian
  Day Number.

  The Julian Day Count has nothing to do with the Julian Calendar introduced by
  Julius Caesar.

  Scaliger chose the particular date in the remote past because it was before
  recorded history and because in that year, three important cycles coincided
  with their first year of the cycle: The 19-year Metonic Cycle, the 15-year
  Indiction Cycle (a Roman Taxation Cycle) and the 28-year Solar Cycle (the
  length of time for the old Julian Calendar to repeat exactly).
  """
  import Calendrical.Math, only: [div_mod: 2]
  @microseconds_in_a_day 86_400_000_000


  @doc """
  Convert a `%Date{}` to a julian day

  ## Example

    iex> Calendrical.JulianDay.date_to_jd(~D[2017-06-30])
    2457934.5
  """
  def date_to_jd(%Date{} = date) do
    date
    |> Calendrical.date_to_rata_die
    |> jd_from_rata_die
  end

  @doc """
  Convert a julian day to a `%Date{}`

  ## Example

    iex> Calendrical.JulianDay.date_from_jd(2457934.5)
    ~D[2017-06-30]
  """
  def date_from_jd(jd) do
    jd
    |> rata_die_from_jd
    |> Calendrical.date_from_rata_die
  end

  def jd_epoch do
    {-1721424, {43_200_000_000, @microseconds_in_a_day}}
  end

  def mjd_epoch do
    {678576, {0, @microseconds_in_a_day}}
  end

  def rata_die_from_jd(jd) do
    to_rata_die(jd, jd_epoch())
  end

  def jd_from_rata_die({_, {_,_}} = rata_die) do
    from_rata_die(rata_die, jd_epoch())
  end

  def rata_die_from_mjd(mjd) do
    to_rata_die(mjd, mjd_epoch())
  end

  def mjd_from_rata_die({_, {_,_}} = rata_die)  do
    from_rata_die(rata_die, mjd_epoch())
  end

  defp from_rata_die({day, {moment, _}}, epoch) do
    {epoch_day, {epoch_moment, _}} = epoch
    {day_increment, microseconds} = div_mod(moment + epoch_moment, @microseconds_in_a_day)
    (day - epoch_day + day_increment) + (microseconds / @microseconds_in_a_day)
  end

  defp to_rata_die(jday, epoch) when is_float(jday) do
    {epoch_day, {epoch_moment, _}} = epoch
    day = trunc(jday)   # The integral part
    moment = (jday - day) * @microseconds_in_a_day # The fractional part in microseconds

    {day_increment, percentage_of_day} = div_mod(moment, epoch_moment)
    day_increment = if day_increment == 1.0, do: 0, else: day_increment

    microseconds = round(percentage_of_day * @microseconds_in_a_day)
    {round(day + epoch_day + day_increment), {microseconds, @microseconds_in_a_day}}
  end

end