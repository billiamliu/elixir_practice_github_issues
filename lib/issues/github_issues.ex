defmodule Issues.GithubIssues do
  @user_agent [ { "User-agent", "Elixir hello@billiam.io" } ]
  @github_url Application.get_env( :issues, :github_url )

  def echo( str ), do: IO.puts str

  def fetch( user, project ) do
    issues_url( user, project )
    |> HTTPoison.get( @user_agent )
    |> handle_response
  end

  def issues_url( user, project ) do
    "#{ @github_url}/repos/#{ user }/#{ project }/issues"
  end

  def handle_response( { :ok, %{ status_code: 200, body: body } } ) do
    { :ok, parseJson( body ) }
  end

  def handle_response( { :error, %{ reason: body } } ) do
    { :error, parseJson( body ) }
  end

  def handle_response( { _, %{ status_code: _, body: body } } ) do
    { :error, parseJson( body ) }
  end

  def parseJson( body ), do: Poison.Parser.parse!( body )

end
