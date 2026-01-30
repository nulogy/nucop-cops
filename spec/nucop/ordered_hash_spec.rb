require "spec_helper"

RSpec.describe Nucop::OrderedHash do
  subject(:cop) { described_class.new }

  it "registers an offense when using ActiveSupport::OrderedHash.new" do
    expect_offense(<<~RUBY)
      hash = ActiveSupport::OrderedHash.new
             ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/OrderedHash: Ruby hashes after 1.9 enumerate keys in order of insertion
    RUBY

    expect_correction(<<~RUBY)
      hash = {}
    RUBY
  end

  it "does not register an offense for regular Hash.new" do
    expect_no_offenses(<<~RUBY)
      hash = Hash.new
    RUBY
  end

  it "does not register an offense for hash literal" do
    expect_no_offenses(<<~RUBY)
      hash = {}
    RUBY
  end

  it "does not register an offense for other ActiveSupport classes" do
    expect_no_offenses(<<~RUBY)
      hash = ActiveSupport::HashWithIndifferentAccess.new
    RUBY
  end
end
