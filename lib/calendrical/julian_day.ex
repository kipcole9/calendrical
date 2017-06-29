defmodule Calendrical.JulianDay do
  @moduledoc """
  Converts `%Date{}` to and from a Julian Day (which is not the same thing as
  a day in the Julian Calendar). Also converts to and from Modified Julian
  Day.

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

  import Calendrical.RataDie


  @doc """
  Returns the epoch for the Julian Day
  as a rata die.
  """
  def jd_epoch do
    {-1721424, {1, 2}}
  end

  @doc """
  Returns the epoch for the Modified Julian Day
  as a rata die.
  """
  def mjd_epoch do
    {678576, {0, 1}}
  end

  @doc """
  Convert a `%Date{}` to a julian day

  ## Example

      iex> Calendrical.JulianDay.date_to_julian_day(~D[2017-06-30])
      2457934.5
  """
  def date_to_julian_day(%Date{} = date) do
    date
    |> Calendrical.date_to_rata_die
    |> julian_day_from_rata_die
  end

  def date_to_julian_day(year, month, day, calendar \\ Calendar.ISO) do
    {:ok, date} = Date.new(year, month, day, calendar)
    date_to_julian_day(date)
  end

  @doc """
  Convert a julian day to a `%Date{}`

  ## Example

      iex> Calendrical.JulianDay.date_from_julian_day(2457934.5)
      ~D[2017-06-30]
  """
  def date_from_julian_day(julian_day, calendar \\ Calendar.ISO) do
    julian_day
    |> rata_die_from_julian_day
    |> Calendrical.date_from_rata_die(calendar)
  end

  @doc """
  Convert a `%Date{}` to a modified julian day

  ## Example

      iex> Calendrical.JulianDay.date_to_modified_julian_day(~D[2017-06-30])
      57934.0
  """
  def date_to_modified_julian_day(%Date{} = date) do
    date
    |> Calendrical.date_to_rata_die
    |> modified_julian_day_from_rata_die
  end

  def date_to_modified_julian_day(year, month, day, calendar \\ Calendar.ISO) do
    {:ok, date} = Date.new(year, month, day, calendar)
    date_to_modified_julian_day(date)
  end

  @doc """
  Convert a modified julian day to a `%Date{}`

  ## Example

      iex> Calendrical.JulianDay.date_from_modified_julian_day(57934.0)
      ~D[2017-06-30]
  """
  def date_from_modified_julian_day(julian_day, calendar \\ Calendar.ISO) do
    julian_day
    |> rata_die_from_modified_julian_day
    |> Calendrical.date_from_rata_die(calendar)
  end

  @doc """
  Convert a rata die to a julian day
  """
  def julian_day_from_rata_die({_, {_,_}} = rata_die) do
    rata_die
    |> sub(jd_epoch())
    |> rata_die_to_float
  end

  @doc """
  Convert a julian day to a rata die
  """
  def rata_die_from_julian_day(jd) do
    jd
    |> rata_die_from_float
    |> add(jd_epoch())
  end

  @doc """
  Convert a rata die to a modified julian day
  """
  def modified_julian_day_from_rata_die({_, {_,_}} = rata_die)  do
    rata_die
    |> sub(mjd_epoch())
    |> rata_die_to_float
  end

  @doc """
  Convert a modified julian day to a rata die
  """
  def rata_die_from_modified_julian_day(mjd) do
    mjd
    |> rata_die_from_float
    |> add(mjd_epoch())
  end


end