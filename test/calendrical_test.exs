defmodule CalendricalTest do
  use ExUnit.Case
  doctest Calendrical
  doctest Calendrical.Kday
  doctest Calendrical.Math
  doctest Calendrical.Math.Fraction
  doctest Calendrical.JulianDay

  Enum.each CalendricalTest.Data.file(1), fn row ->
    for c <- ["julian", "gregorian", "coptic", "egyptian", "armenian"] do
      import CalendricalTest.Helpers

      # Test that a date in a calendar correctly converts to a rata die
      test "that the #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)} equals RD #{row[:rd]}" do
        days = module(unquote(c)).date_to_rata_die_days(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)))
        assert days == unquote(row[:rd])
      end

      # Test that a rata die converts correctly to a date in a calendar
      test "that the RD #{row[:rd]} equals #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)}" do
        j_date = module(unquote(c)).date_from_rata_die_days(unquote(row[:rd]))
        {:ok, date} = Date.new(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)), module(unquote(c)))
        assert date == j_date
      end

      # Test that a date in a calendar converts correctly to a Julian Day
      test "that the #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)} equals Julian Day #{row[:j_day]}" do
        {:ok, date} = Date.new(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)), module(unquote(c)))
        days = Calendrical.JulianDay.date_to_julian_day(date)
        assert days == unquote(row[:j_day])
      end

      # Test that a Julian Day correctly converts to a date
      test "that the Julian Day #{row[:j_day]} equals #{module_name(c)} #{year(row, c)}-#{month(row, c)}-#{day(row, c)}" do
        j_date = Calendrical.JulianDay.date_from_julian_day(unquote(row[:j_day]), module(unquote(c)))
        {:ok, date} = Date.new(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)), module(unquote(c)))
        assert date == j_date
      end

      # Tests that a date is correctly identified as the right day of week
      test "that the #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)} is a #{row[:weekday]}" do
        {:ok, date} = Date.new(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)), module(unquote(c)))
        day_cardinal = Calendrical.day_of_week(date)
        assert Calendrical.Kday.day_name(day_cardinal) == unquote(row[:weekday])
      end
    end
  end

  Enum.each CalendricalTest.Data.file(2), fn row ->
    for c <- ["ethiopic"] do
      import CalendricalTest.Helpers

      # Test that a date in a calendar correctly converts to a rata die
      test "that the #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)} equals RD #{row[:rd]}" do
        days = module(unquote(c)).date_to_rata_die_days(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)))
        assert days == unquote(row[:rd])
      end

      # Test that a rata die converts correctly to a date in a calendar
      test "that the RD #{row[:rd]} equals #{module_name(c)} date #{year(row, c)}-#{month(row, c)}-#{day(row, c)}" do
        j_date = module(unquote(c)).date_from_rata_die_days(unquote(row[:rd]))
        {:ok, date} = Date.new(year(unquote(row), unquote(c)), month(unquote(row), unquote(c)), day(unquote(row), unquote(c)), module(unquote(c)))
        assert date == j_date
      end
    end
  end
end
