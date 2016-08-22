defmodule GithubIssuesTest do

  use ExUnit.Case

  import Issues.GithubIssues, only: [ parseJson: 1 ]

  test "parse a simple json" do
    assert parseJson( "{\"key\": \"val\"}" ) == %{ "key" => "val" }
  end

end
