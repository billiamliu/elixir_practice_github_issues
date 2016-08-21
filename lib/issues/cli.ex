defmodule Issues.CLI do

  import Issues.TableFormatter, only: [ print_table_for_columns: 2 ]

  @default_count 4

  @moduledoc """
  Handles command line input
  """

  def main( argv ) do
    argv
    |> parse_args
    |> process
  end

  @doc """
  `argv` can be -h or --help, which returs :help

  Otherwise it is a github username, project name, and [number of entries to format]

  Returns a tuple of `{ user, project count }`, or `:help` if help was given
  """
  def parse_args( argv ) do
    parse = OptionParser.parse( argv, switches: [ help: :boolean ],
                                      aliases:  [ h:    :help    ] )
    case parse do
        { [ help: true ], _, _ } -> :help

        { _, [ user, project, count ], _ } -> { user, project, String.to_integer( count ) }

        { _, [ user, project ], _ } -> { user, project, @default_count }

        _ -> :help
    end
  end

  def process( :help ) do
    IO.puts """
    usage: issues <user> <project> [ count | #{ @default_count } ]
    """

    System.halt( 0 )
  end

  def process( { user, project, count } ) do # _unused variable, compiler ignore
    Issues.GithubIssues.fetch( user, project )
    |> decode_response
    |> convert_to_maps
    |> sort_ascending
    |> Enum.take( count )
    |> print_table_for_columns( [ "number", "created_at", "title" ] )
  end

  def decode_response( { :ok, body } ), do: body

  def decode_response( { :error, err } ) when is_list( err ) do
    { _, message } = List.keyfind( err, "message", 0 )
    IO.puts "Error fetching from Github: #{ message }"
    System.halt( 2 )
  end

  def decode_response( { :error, err } ) do
    error = Enum.to_list( err )
    decode_response( { :error, error } )
  end

  def convert_to_maps( list ) do
    list
    |> Enum.map( &Enum.into( &1, Map.new ) )
  end

  def sort_ascending( list ) do
    list
    |> Enum.sort( &( &1["created_at"] <= &2["created_at"] ) )
  end

end
