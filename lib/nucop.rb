require "nucop/version"

require "rubocop"

Dir[File.join(__dir__, "nucop/helpers/**/*.rb")].each { |f| require f }
Dir[File.join(__dir__, "nucop/cops/**/*.rb")].each { |f| require f }

module Nucop
end
