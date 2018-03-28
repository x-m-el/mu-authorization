defmodule Parser do
  @moduledoc """
  Parser for the W3C EBNF syntax.
  """

  def split_single_form( string ) do
    IO.puts( string )
    split_string = String.split( string , "::=", parts: 2 )
    [name, clause] = Enum.map( split_string , &String.trim/1 )
    { name, full_parse( clause ) }
  end

  def split_forms( forms ) do
    Enum.map( forms, &split_single_form/1 )
  end

  def parse_sparql() do
    split_forms( EbnfParser.Forms.sparql )
  end


  @doc """
  ## Examples
  iex> Parser.full_parse( "FOO" )
  [{ :symbol, "FOO" }]

  iex> Parser.full_parse( "FOO BAR" )
  [{ :symbol, "BAR" }, {:symbol, "FOO"}]

  iex> Parser.full_parse( "( FOO BAR )" )
  [paren_group: [ symbol: "BAR", symbol: "FOO"]]

  iex> Parser.full_parse( "( FOO BAR )*" )
  [maybe_many: [paren_group: [ symbol: "BAR", symbol: "FOO"]]]

  iex> Parser.full_parse( "( FOO BAR* (FOO|BAR) )+" )
  [one_or_more: [ paren_group: [ paren_group: [ one_of: [ symbol: "BAR", symbol: "FOO" ] ], maybe_many: [ symbol: "BAR" ], symbol: "FOO" ]]]

  iex Parser.full_parse( "

  """
  def full_parse( string ) do
    IO.inspect string
    code_string = String.codepoints( string )
    tokens = EbnfParser.Tokenizer.ebnf_tokenizer( { :default }, code_string )
    EbnfParser.Parser.ebnf_parser( tokens )
  end



end
