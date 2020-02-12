# frozen_string_literal: true

class MarkdownParser
  def self.render(string)
    parser.render(string)
  end

  def self.parser
    @parser ||= initialize_parser
  end

  def self.initialize_parser
    Redcarpet::Markdown.new(Redcarpet::Render::HTML.new)
  end
end
