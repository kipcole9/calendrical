# Calendrical

  `Calendrical ` provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Reingold.  This `rata die` gives a numerical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  `Calendrical` implements:

  * K-Day calculations in `Calendrical.Kday`

  * Julian Day conversion in `Calendrical.JulianDay`. Note this is not the same thing as the Julian calendar.

  * Contemporary calendars:

    * `Calendrical.Calendar.Gregorian` that is largely the same as the standard Elixir `Calendar.ISO`.  The standard should be preferred
    * `Calendrical.Calendar.Persian` that implements the Arithmetic Persian calendar

  *  Several calendars of primarily historic usage:

    * `Calendrical.Calendar.Armenian`
    * `Calendrical.Calendar.Coptic`
    * `Calendrical.Calendar.Egyptian`
    * `Calendrical.Calendar.Ethiopic`
    * `Calendrical.Calendar.Julian`

## Example Usage

`Date.new/4` is used to create a calendar with the default calendar being `Calendar.ISO`.  To create a date using one of the `Calendrical` calendars simply:

    iex> Date.new(2017,1,1,Calendrical.Calendar.Gregorian)
    {:ok,
     %Date{calendar: Calendrical.Calendar.Gregorian, day: 1, month: 1, year: 2017}}

    iex> Date.new(2017,1,1,Calendrical.Calendar.Egyptian)
    {:ok,
     %Date{calendar: Calendrical.Calendar.Egyptian, day: 1, month: 1, year: 2017}}

To convert a date from one calendar to another use the `Date.convert/2` or `Date.convert!/2` functions.  For example:

    iex> Date.convert! ~D[2016-07-01], Calendrical.Calendar.Julian
    %Date{calendar: Calendrical.Calendar.Julian, day: 18, month: 6, year: 2016}

Note that dates can only be converted if the calendars both have the same definition of the start of day.  Some calendars define the start of day various as sunrise, sunset, noon and midnight.   To convert calendars with different notions of when the day starts the time of day will need to be specified hence `DateTime.convert/2` is required.

    iex> dt1 = %DateTime{calendar: Calendar.ISO, day: 29, hour: 23, microsecond: {0, 0},
     minute: 0, month: 2, second: 7, std_offset: 0, time_zone: "America/Manaus",
     utc_offset: -14400, year: 2000, zone_abbr: "AMT"}

    iex> DateTime.convert(dt1, Calendrical.Calendar.Julian)
    {:ok,
     %DateTime{calendar: Calendrical.Calendar.Julian, day: 16, hour: 23, microsecond: {0, 6},
      minute: 0, month: 2, second: 7, std_offset: 0, time_zone: "America/Manaus",
      utc_offset: -14400, year: 2000, zone_abbr: "AMT"}}

## Roadmap

  - [ ] Date and time formatting which will be done in a locale sensitive way through the [ex_cldr](https://hex.pm/packages/ex_cldr) package after it is updated to provide that support.  Expected in July 2017.

  - [ ] Hebrew and Islamic calendars (the arithmetic versions) are expected to land in July 2017

  - [ ]  Astronomical calendar types will be implemented but only after the required astronomy library is built (ie not expected before year end 2017)

## Elixir Version Support

`Calendrical` requires Elixir 1.5 or later.  It is tested on Elixir 1.5.0-rc.0

## Installation

1. Add `calendrical` to your list of dependencies in `mix.exs`:

```elixir
    def deps do
      [{:calendrical, "~> 0.1.2"}]
    end
```

2. Ensure `calendrical` is started before your application:

```elixir
    def application do
      [applications: [:calendrical]]
    end
```

The docs can be found at [https://hexdocs.pm/calendrical](https://hexdocs.pm/calendrical)

