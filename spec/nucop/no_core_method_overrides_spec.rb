require "spec_helper"

RSpec.describe Nucop::NoCoreMethodOverrides do
  subject(:cop) { described_class.new }

  it "registers an offense when overriding blank?" do
    expect_offense(<<~RUBY)
      def blank?
      ^^^^^^^^^^ Nucop/NoCoreMethodOverrides: Core method overridden
        false
      end
    RUBY
  end

  it "registers an offense when overriding present?" do
    expect_offense(<<~RUBY)
      def present?
      ^^^^^^^^^^^^ Nucop/NoCoreMethodOverrides: Core method overridden
        true
      end
    RUBY
  end

  it "registers an offense when overriding empty?" do
    expect_offense(<<~RUBY)
      def empty?
      ^^^^^^^^^^ Nucop/NoCoreMethodOverrides: Core method overridden
        true
      end
    RUBY
  end

  it "does not register an offense for other method names" do
    expect_no_offenses(<<~RUBY)
      def my_custom_method?
        true
      end
    RUBY
  end

  it "does not register an offense for methods with similar names" do
    expect_no_offenses(<<~RUBY)
      def is_blank?
        false
      end
    RUBY
  end
end
