# Calendrical

  `Calendrical ` provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Reingold.  This `rata die` gives a numberical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  Calendrical implements:

  * K-Day calculations in `Calendrical.Kday`

  * A calendar `Calendrical.Calendar.Gregorian` that is largely the same as the standard Elixir `Calendar.ISO`.  The standard should be preferred

  *  Several calendars of primarily historic usage:

    * Armenian
    * Coptic
    * Egyptian
    * Ethiopic

## Roadmap

  - [ ] Date and time formatting which will be done in a locale sensitive way through the [ex_cldr](https://hex.pm/packages/ex_cldr) package after it is updated to provide that support.  Expected in July 2017.

  - [ ] Hebrew, Islamic and Persian calendars (the arithmetic versions) are expected to land in July 2017

  - [ ]  Astronomical calendar types will be implemented but only after the required astronomy library is built (ie not expected before year end 2017)

## Elixir Version Support

`Calendrical` requires Elixir 1.5 or later.  It is tested on Elixir 1.5.0-rc.0

## Installation

1. Add `calendrical` to your list of dependencies in `mix.exs`:

```elixir
    def deps do
      [{:calendrical, "~> 0.1.1"}]
    end
```

2. Ensure `calendrical` is started before your application:

```elixir
    def application do
      [applications: [:calendrical]]
    end
```

The docs can be found at [https://hexdocs.pm/calendrical](https://hexdocs.pm/calendrical)

