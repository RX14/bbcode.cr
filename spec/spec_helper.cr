require "spec2"
require "power_assert"
require "../src/bbcode"

TAG_IDENTITY_PROC = ->(tag_name : String, content : String, attributes : Hash(String, String)) {
  "<#{tag_name}>#{content}</#{tag_name}>"
}

BBCODE = BBCode.new({
  "b"      => TAG_IDENTITY_PROC,
  "i"      => TAG_IDENTITY_PROC,
  "center" => TAG_IDENTITY_PROC
})

def render(string)
  String.build do |b|
    BBCODE.render(string, b)
  end
end

# Remove some html escaping for test readability
HTML::SUBSTITUTIONS.reject!('[', ']', '\'', '(', ')')

Spec2.random_order
Spec2.doc
