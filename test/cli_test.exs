defmodule CliTest do

  use ExUnit.Case
  doctest Issues

  import Issues.CLI, only: [ parse_args: 1, sort_ascending: 1, convert_to_maps: 1 ]

  test ":help returned by option parsing with -h and --help options" do
    assert parse_args([ "-h",     "anything" ]) == :help
    assert parse_args([ "--help", "anything" ]) == :help
  end

  test "three values returned if three given" do
    assert parse_args([ "user", "project", "99" ]) == { "user", "project", 99 }
  end

  test "default count if only first two values given" do
    assert parse_args([ "user", "project" ]) == { "user", "project", 4 }
  end

  # the test used in << Programing Elixir >>
  test "sort in ascending order" do
    result = sort_ascending( fake_created_at_list( [ "c", "a", "b" ] ) )
    issues = for issue <- result, do: issue[ "created_at" ]
    assert issues == ~w{ a b c }
  end

  # playing with piping things
  test "sort ascending but using pipes in test" do
    result = 5..1
      |> fake_created_at_list
      |> sort_ascending
      |> Enum.map( &( &1[ "created_at" ] ) )

    assert result == Enum.to_list 1..5
  end

  defp fake_created_at_list( values ) do
    data = for value <- values, do: [ { "created_at", value }, { "other_data", "xxx" } ]

    convert_to_maps data
  end

end
