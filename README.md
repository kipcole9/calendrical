# Calendrical

  `Calendrical ` provides calendar-related functions that build upon the
  conversion capabilities of `Calendar` available in Elixir from verison 1.5.0.

  The conversion mechanism is based upon the definition of `rata die` as described
  in [Calendrical Calculations](https://www.amazon.com/Calendrical-Calculations-Nachum-Dershowitz/dp/0521702380)
  by Dershowitz and Rheingold.  This `rata die` gives a numberical value to a moment in time
  that is idependent of any specific calendar.  As a result libraries such as `Calendrical` can
  implement different calendars and calendar calculations in a conformant way.

  Calendrical implements:

  * K-Day calculations in `Calendrical.Kday`

  * Additional Arithmetic calendar types (Julian calendar in the first release)

  * Astronomical calendar types (in a future release)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `calendrical` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:calendrical, "~> 0.1.0"}]
    end
    ```

  2. Ensure `calendrical` is started before your application:

    ```elixir
    def application do
      [applications: [:calendrical]]
    end
    ```

If [published on HexDocs](https://hex.pm/docs/tasks#hex_docs), the docs can
be found at [https://hexdocs.pm/calendrical](https://hexdocs.pm/calendrical)

