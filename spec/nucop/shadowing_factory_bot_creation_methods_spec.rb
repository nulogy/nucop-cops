require "spec_helper"

RSpec.describe Nucop::ShadowingFactoryBotCreationMethods do
  subject(:cop) { described_class.new }

  let(:spec_file) { "modules/mymodule/spec/my_spec.rb" }

  it "registers an offense when defining a method named create" do
    expect_offense(<<~RUBY, spec_file)
      def create(args)
      ^^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `create` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "registers an offense when defining a method named build" do
    expect_offense(<<~RUBY, spec_file)
      def build(args)
      ^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `build` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "registers an offense when defining a method named build_list" do
    expect_offense(<<~RUBY, spec_file)
      def build_list(args)
      ^^^^^^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `build_list` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "registers an offense when defining a method named create_list" do
    expect_offense(<<~RUBY, spec_file)
      def create_list(args)
      ^^^^^^^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `create_list` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "registers an offense when defining a method named attributes_for" do
    expect_offense(<<~RUBY, spec_file)
      def attributes_for(args)
      ^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `attributes_for` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "registers an offense when defining a method named build_stubbed" do
    expect_offense(<<~RUBY, spec_file)
      def build_stubbed(args)
      ^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ShadowingFactoryBotCreationMethods: Method `build_stubbed` shadows a FactoryBot method. Please rename it to be more specific.
        # ...
      end
    RUBY
  end

  it "does not register an offense for methods with specific names" do
    expect_no_offenses(<<~RUBY, spec_file)
      def create_transfer_pallet(args)
        # ...
      end
    RUBY
  end

  it "does not register an offense for unrelated method names" do
    expect_no_offenses(<<~RUBY, spec_file)
      def my_custom_method(args)
        # ...
      end
    RUBY
  end

  it "does not register an offense for non-spec files" do
    expect_no_offenses(<<~RUBY, "app/models/job.rb")
      def create(args)
        # ...
      end
    RUBY
  end
end
