require "spec_helper"

RSpec.describe Nucop::NoWipSpecs do
  subject(:cop) { described_class.new }

  it "registers an offense when it block has :wip tag" do
    expect_offense(<<~RUBY)
      it "tests some stuff", :wip do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/NoWipSpecs: WIP spec found
        expect(true).to be true
      end
    RUBY
  end

  it "registers an offense when describe block has :wip tag" do
    expect_offense(<<~RUBY)
      describe "SomeClass", :wip do
      ^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/NoWipSpecs: WIP spec found
        it "does something" do
          expect(true).to be true
        end
      end
    RUBY
  end

  it "does not register an offense for it blocks without :wip" do
    expect_no_offenses(<<~RUBY)
      it "tests some stuff" do
        expect(true).to be true
      end
    RUBY
  end

  it "does not register an offense for describe blocks without :wip" do
    expect_no_offenses(<<~RUBY)
      describe "SomeClass" do
        it "does something" do
          expect(true).to be true
        end
      end
    RUBY
  end

  it "does not register an offense for other tags" do
    expect_no_offenses(<<~RUBY)
      it "tests some stuff", :slow do
        expect(true).to be true
      end
    RUBY
  end
end
