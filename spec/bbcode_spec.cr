require "./spec_helper"

Spec2.describe BBCode do
  describe ".render" do
   context "input validation tests" do
     it "Unknown tags like [foo] get ignored." do
       bbcode = "This is [foo]a tag[/foo]."
       html = "This is [foo]a tag[/foo]."
       assert render(bbcode) == html
     end

     it "Broken tags like [foo get ignored." do
       bbcode = "This is [foo a tag."
       html = "This is [foo a tag."
       assert render(bbcode) == html
     end

     it "Broken tags like [/foo get ignored." do
       bbcode = "This is [/foo a tag."
       html = "This is [/foo a tag."
       assert render(bbcode) == html
     end

     it "Broken tags like [] get ignored." do
       bbcode = "This is [] a tag."
       html = "This is [] a tag."
       assert render(bbcode) == html
     end

     it "Broken tags like [/  ] get ignored." do
       bbcode = "This is [/  ] a tag."
       html = "This is [/  ] a tag."
       assert render(bbcode) == html
     end

     it "Broken tags like [/ get ignored." do
       bbcode = "This is [/ a tag."
       html = "This is [/ a tag."
       assert render(bbcode) == html
     end

     it "Broken [ tags before [b]real tags[/b] don't break the real tags." do
       bbcode = "Broken [ tags before [b]real tags[/b] don't break the real tags."
       html = "Broken [ tags before <b>real tags</b> don't break the real tags."
       assert render(bbcode) == html
     end

     it "Broken [tags before [b]real tags[/b] don't break the real tags." do
       bbcode = "Broken [tags before [b]real tags[/b] don't break the real tags."
       html = "Broken [tags before <b>real tags</b> don't break the real tags."
       assert render(bbcode) == html
     end

     it "[i][b]Mis-ordered nesting[/i][/b] gets fixed." do
       bbcode = "[i][b]Mis-ordered nesting[/i][/b] gets fixed."
       html = "<i><b>Mis-ordered nesting</b></i> gets fixed."
       assert render(bbcode) == html
     end

     it "[url=][b]Mis-ordered nesting[/url][/b] gets fixed." do
       bbcode = "[url=http://www.google.com][b]Mis-ordered nesting[/url][/b] gets fixed."
       html = "<a href=\"http://www.google.com\" class=\"bbcode_url\"><b>Mis-ordered nesting</b></a> gets fixed."
       assert render(bbcode) == html
     end

     it "[i]Unended blocks are automatically ended." do
       bbcode = "[i]Unended blocks are automatically ended."
       html = "<i>Unended blocks are automatically ended.</i>"
       assert render(bbcode) == html
     end

     it "Unstarted blocks[/i] have their end tags ignored." do
       bbcode = "Unstarted blocks[/i] have their end tags ignored."
       html = "Unstarted blocks[/i] have their end tags ignored."
       assert render(bbcode) == html
     end

     it "[b]Mismatched tags[/i] are not matched to each other." do
       bbcode = "[b]Mismatched tags[/i] are not matched to each other."
       html = "<b>Mismatched tags[/i] are not matched to each other.</b>"
       assert render(bbcode) == html
     end

     it "[center]Inlines and [b]blocks get[/b] nested correctly[/center]." do
       bbcode = "[center]Inlines and [b]blocks get[/b] nested correctly[/center]."
       html = "<center>Inlines and <b>blocks get</b> nested correctly</center>."
       assert render(bbcode) == html
     end

     it "[b]Inlines and [center]blocks get[/center] nested correctly[/b]." do
       bbcode = "[b]Inlines and [center]blocks get[/center] nested correctly[/b]."
       html = "<b>Inlines and <center>blocks get</center> nested correctly</b>."
       assert render(bbcode) == html
     end

     it "BBCode is [B]case-insensitive[/b]." do
       bbcode = "[cEnTeR][b]This[/B] is a [I]test[/i].[/CeNteR]"
       html = "<center><b>This</b> is a <i>test</i>.</center>"
       assert render(bbcode) == html
     end

     it "Plain text gets passed through unchanged." do
       bbcode = "Plain text gets passed through unchanged.  b is not a tag and i is not a tag and neither is /i and neither is (b)."
       html = "Plain text gets passed through unchanged.  b is not a tag and i is not a tag and neither is /i and neither is (b)."
       assert render(bbcode) == html
     end
   end
  end
end
