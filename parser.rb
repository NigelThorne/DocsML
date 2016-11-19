require 'rubygems'
require 'parslet'
 
module DocsML
#This needs a few more 'as' calls to annotate the output 
class DocsMLParser < Parslet::Parser
  def initialize(number_parser)
    @number_parser
  end
 
  rule(:space)              { match('[\s\n]').repeat(1) }
  rule(:space?)             { space.maybe }
  rule(:digit)              { match('[0-9]') }
  rule(:hexdigit)           { match('[0-9a-fA-F]') }
  rule(:_comma_)            { space? >> str(',') >> space? }
  rule(:_colon_)            { space? >> str(':') >> space? }
 
  rule(:number)             { @number_parser }
 
  rule(:escaped_character)  { str('\\') >> (match('["\\\\/bfnrt]') | (str('u') >> hexdigit.repeat(4,4))) }
 
  rule(:string){ 
     str('"') >> (
        escaped_character | str('"').absent? >> any)
     ).repeat.as(:string) >> str('"') 
  }
 
  rule(:value){ 
     (string | 
      number | 
      object | 
      array  | 
      str('true').as(:true) | 
      str('false').as(:false) | 
      str('null').as(:null)).as(:val) 
  }
 
  rule(:entry)              { string >> _colon_ >> value }
  rule(:pair_list)          { entry >> (_comma_ >> entry).repeat(0) }
  rule(:object)             { str('{') >> space? >> pair_list.maybe >> space? >> str('}') }
 
  rule(:value_list)         { value >> (_comma_ >> value).repeat }
  rule(:array)              { str('[') >> space? >> value_list.maybe >> space? >> str(']')}
 
  rule(:_docsml_)             { space? >> value >> space?}
  root(:_docsml_)
end
 
class NumberParser < ParsletParser
  rule(:space)              { match('[\s\n]').repeat(1)}
  rule(:space?)             { space.maybe }
  rule(:digit)              { match('[0-9]') }
 
  rule(:number) {
    space? >> 
    str('-').maybe >> 
    ( str('0') | ( match('[1-9]') >> digit.repeat) ) >> 
    ( str('.') >> digit.repeat ).maybe >> 
    ( ( str('e') | str('E') ) >> 
      ( str('+') | str('-') ).maybe >> 
      digit.repeat 
    ).maybe
  }
 
  root(:number)
end




json_parser = DocsMLParser.new(NumberParser.new)