require "spec_helper"

RSpec.describe Nucop::ExplicitFactoryBotUsage do
  subject(:cop) { described_class.new }

  let(:spec_file) { "modules/mymodule/spec/my_spec.rb" }

  describe "FactoryGirl usage" do
    it "registers an offense for FactoryGirl.create and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        job = FactoryGirl.create(:job, project: project)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryGirl` to build objects. The factory method `create` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        job = create(:job, project: project)
      RUBY
    end

    it "registers an offense for FactoryGirl.build and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        job = FactoryGirl.build(:job)
              ^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryGirl` to build objects. The factory method `build` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        job = build(:job)
      RUBY
    end
  end

  describe "FactoryBot usage" do
    it "registers an offense for FactoryBot.create and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        job = FactoryBot.create(:job, project: project)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `create` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        job = create(:job, project: project)
      RUBY
    end

    it "registers an offense for FactoryBot.build and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        job = FactoryBot.build(:job)
              ^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `build` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        job = build(:job)
      RUBY
    end

    it "registers an offense for FactoryBot.build_list and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        jobs = FactoryBot.build_list(:job, 3)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `build_list` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        jobs = build_list(:job, 3)
      RUBY
    end

    it "registers an offense for FactoryBot.create_list and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        jobs = FactoryBot.create_list(:job, 3)
               ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `create_list` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        jobs = create_list(:job, 3)
      RUBY
    end

    it "registers an offense for FactoryBot.attributes_for and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        attrs = FactoryBot.attributes_for(:job)
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `attributes_for` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        attrs = attributes_for(:job)
      RUBY
    end

    it "registers an offense for FactoryBot.build_stubbed and autocorrects" do
      expect_offense(<<~RUBY, spec_file)
        job = FactoryBot.build_stubbed(:job)
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Nucop/ExplicitFactoryBotUsage: Do not explicitly use `FactoryBot` to build objects. The factory method `build_stubbed` is globally available.
      RUBY

      expect_correction(<<~RUBY)
        job = build_stubbed(:job)
      RUBY
    end
  end

  it "does not register an offense for direct factory method calls" do
    expect_no_offenses(<<~RUBY, spec_file)
      job = create(:job, project: project)
    RUBY
  end

  it "does not register an offense for other method calls on FactoryBot" do
    expect_no_offenses(<<~RUBY, spec_file)
      FactoryBot.define do
        factory :job do
          name { "Test Job" }
        end
      end
    RUBY
  end

  it "does not register an offense for non-spec files" do
    expect_no_offenses(<<~RUBY, "app/models/job.rb")
      job = FactoryBot.create(:job)
    RUBY
  end
end
