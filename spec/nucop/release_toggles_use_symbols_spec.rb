require "spec_helper"

RSpec.describe Nucop::ReleaseTogglesUseSymbols do
  subject(:cop) { described_class.new }

  describe "test helper methods" do
    it "registers an offense when release_toggle_enabled? uses a string" do
      expect_offense(<<~RUBY)
        release_toggle_enabled?("my_toggle")
                                ^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY
    end

    it "registers an offense when release_toggle_enabled_for_any_site? uses a string" do
      expect_offense(<<~RUBY)
        release_toggle_enabled_for_any_site?("my_toggle")
                                             ^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY
    end

    it "does not register an offense when release_toggle_enabled? uses a symbol" do
      expect_no_offenses(<<~RUBY)
        release_toggle_enabled?(:my_toggle)
      RUBY
    end
  end

  describe "ReleaseToggles public API" do
    it "registers an offense for ReleaseToggles.enabled? with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.enabled?("test_toggle", site_id: site_id)
                                ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.enabled?(:test_toggle, site_id: site_id)
      RUBY
    end

    it "registers an offense for ReleaseToggles.disabled? with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.disabled?("test_toggle", site_id: site_id)
                                 ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.disabled?(:test_toggle, site_id: site_id)
      RUBY
    end

    it "registers an offense for ReleaseToggles.enable with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.enable("test_toggle", site_id: site_id)
                              ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.enable(:test_toggle, site_id: site_id)
      RUBY
    end

    it "registers an offense for ReleaseToggles.disable with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.disable("test_toggle", site_id: site_id)
                               ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.disable(:test_toggle, site_id: site_id)
      RUBY
    end

    it "registers an offense for ReleaseToggles.enable! with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.enable!("test_toggle", site_id: site_id)
                               ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.enable!(:test_toggle, site_id: site_id)
      RUBY
    end

    it "registers an offense for ReleaseToggles.disable! with string and autocorrects" do
      expect_offense(<<~RUBY)
        ReleaseToggles.disable!("test_toggle", site_id: site_id)
                                ^^^^^^^^^^^^^ Nucop/ReleaseTogglesUseSymbols: Use a symbol when referring to a Release Toggle's by name
      RUBY

      expect_correction(<<~RUBY)
        ReleaseToggles.disable!(:test_toggle, site_id: site_id)
      RUBY
    end

    it "does not register an offense when using symbols" do
      expect_no_offenses(<<~RUBY)
        ReleaseToggles.enabled?(:test_toggle, site_id: site_id)
      RUBY
    end
  end
end
