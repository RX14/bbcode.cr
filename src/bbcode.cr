require "html"

class BBCode
  @tags : Hash(String, Proc(String, String, Hash(String, String), String))

  @tag_start_char = '['
  @tag_end_char = ']'

  def initialize(@tags, @tag_start_char = '[', @tag_end_char = ']')
  end

  macro next_char
    index += 1
    char = chars.at(index) { '\0' }
    char
  end

  macro ignore_char
    io << escape(char)

    next_char
  end

  macro ignore_tag
    io << escape(tag_start_char)
    HTML.escape(tag_name, io)
    io << escape(char)

    next_char
  end

  macro skip_whitespace
    while char.whitespace?
      next_char
    end
  end

  def render(str)
    String.build do |b|
      render(str, b)
    end
  end

  def render(src, io)
    tags = @tags
    tag_start_char = @tag_start_char
    tag_end_char = @tag_end_char
    tag_names = tags.keys

    chars = src.chars
    index = 0

    while index < chars.size
      char = chars[index]

      unless char == tag_start_char
        ignore_char
        next
      end

      # Begin parsing tag
      next_char # Eat TAG_START_CHAR

      tag_name = String.build do |b|
        while char.alpha? || char == '-' || char == '*'
          b << char
          next_char
        end
      end

      tag_name_lowercase = tag_name.downcase
      if tag_names.none? { |tag| tag_name_lowercase == tag }
        ignore_tag
        next
      end
      tag_name = tag_name_lowercase

      content = ""
      attributes = {} of String => String

      # char is the character after the tag name
      skip_whitespace
      case char
      when tag_end_char # Simple tag
        next_char # Eat TAG_END_CHAR
      when '=' # Single parameter tag
        next_char # Eat =
        skip_whitespace

        if char == '\'' || char == '"'
          quotechar = char
        else
          quotechar = ' '
        end

        next_char

        param_start = index
        while char != quotechar && char != tag_end_char && char != '\0'
          next_char
        end
        param_end = index

        param = String.build do |b|
          (param_start..param_end).each { |i| b << chars[i] }
        end

        attributes["value"] = param
      end

      # Find end tag
      content_start_index = index
      end_tag_found = false
      while true
        # Find next tag
        while char != tag_start_char && char != '\0'
          next_char
        end

        # End of string
        if char == '\0'
          # Automatically end tag
          end_tag_found = true

          content = String.build do |b|
            (content_start_index...index).each { |i| b << chars[i] }
          end

          content = String.build do |b|
            self.render(content, b)
          end

          break
        end

        content_end_index = index - 1

        # Ignore start tags
        next unless next_char == '/'

        # Compare with start tag name
        matches = true
        tag_name.each_char do |c|
          if next_char.downcase != c
            matches = false
            break
          end
        end
        next unless matches

        next unless next_char == tag_end_char
        next_char # Eat TAG_END_CHAR

        end_tag_found = true
        content = String.build do |b|
          (content_start_index..content_end_index).each { |i| b << chars[i] }
        end

        # Any end tags directly after the end tag must be out of order
        extra_tags = String.build do |b|
          while char == tag_start_char
            start_index = index

            next_char # Eat TAG_START_CHAR

            # Ingore start tags
            next unless char == '/'

            # Eat name
            next_char
            while char.alpha? || char == '-' || char == '*'
              next_char
            end

            next unless char == tag_end_char

            # This is an end tag, add to StringBuilder
            end_index = index

            (start_index..end_index).each { |i| b << chars[i] }

            next_char
          end
        end

        content += extra_tags

        content = String.build do |b|
          self.render(content, b)
        end

        # Counteract index += 1 at end of main loop
        index -= 1
        break
      end
      
      unless end_tag_found
        index = content_start_index - 1
      end

      handler_proc = tags[tag_name]
      io << handler_proc.call(tag_name, content, attributes)

      index += 1
    end
  end

  @[AlwaysInline]
  private def escape(char)
    HTML::SUBSTITUTIONS.fetch(char, char)
  end
end
