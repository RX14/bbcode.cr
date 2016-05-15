require "./spec_helper"
def render(string)
  String.build do |b|
    BBCode.render(string, b)
  end
end

describe BBCode do
  it "parses basic bbcode" do
    puts render "[i][b]Mis-ordered nesting[/i][/b] gets fixed."
  end
end
