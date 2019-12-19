module Reviewbear::Helper
  module String
    def cut_off(text, length)
      if text.length < length
        text
      else
        text.scan(/^.{#{length}}/m)[0] + "…"
      end
    end
  end
end
