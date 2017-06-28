defmodule Calendrical.JulianDay do
  @moduledoc """
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

  def epoch_origin do
    0
  end

  def rd(tee) do
    tee - epoch_origin()
  end

  def jd_epoch do
    rd(-1721424.5)
  end

  def mjd_epoch do
    rd(678576)
  end

  def moment_from_jd(jd) do
    jd + jd_epoch()
  end

  def jd_from_moment(tee) do
    tee - jd_epoch()
  end

  def universal_date_from_jd(jd) do
    jd
    |> moment_from_jd
    |> Float.floor
  end

  def jd_from_universal_date(date) when is_integer(date) do
    jd_from_moment(date)
  end

  def universal_date_from_mjd(mjd) do
    mjd + mjd_epoch()
  end

  def mjd_from_universal_date(date) when is_integer(date) do
    date - mjd_epoch()
  end
end