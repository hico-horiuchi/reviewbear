module Reviewbear::Handler
  class Version
    def exec(**args)
      puts "v#{Reviewbear::VERSION}"
    end
  end
end
