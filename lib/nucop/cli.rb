require "thor"
require "open3"
require "net/http"
require "json"

RUBOCOP_DEFAULT_CONFIG_FILE = ".rubocop.yml"
CONFIGURATION_FILEPATH = ".nucop.yml"

module Nucop
  class Cli < Thor
    class << self
      private

      def load_custom_options
        @_load_custom_options ||=
          if File.exist?(CONFIGURATION_FILEPATH)
            default_configuration.merge(YAML.load_file(CONFIGURATION_FILEPATH, symbolize_names: true))
          else
            default_configuration
          end
      end

      def default_configuration
        {
          rubocop_todo_file: ".rubocop_todo.yml",
          diffignore_file: ".nucop_diffignore"
        }
      end
    end

    class_option :diffignore_file, default: load_custom_options[:diffignore_file]
    class_option :rubocop_todo_file, default: load_custom_options[:rubocop_todo_file]

    desc "diff_enforced", "run RuboCop on the current diff using only the enforced cops"
    method_option "commit-spec", default: "origin/main", desc: "the commit used to determine the diff."
    method_option "auto-correct", type: :boolean, default: false, desc: "runs RuboCop with auto-correct option (deprecated)"
    method_option "autocorrect", type: :boolean, default: false, desc: "runs RuboCop with autocorrect option"
    method_option "autocorrect-all", type: :boolean, default: false, desc: "runs RuboCop with autocorrect-all option"
    method_option "junit_report", type: :string, default: nil, desc: "runs RuboCop with junit formatter option"
    method_option "json", type: :string, default: nil, desc: "Output results as JSON format to the provided file"

    def diff_enforced
      invoke :diff, nil, options
    end

    desc "diff_enforced_github", "run RuboCop on the current diff using only the enforced cops (using GitHub to find the files changed)"
    method_option "github-authorization-token", desc: "a GitHub authorization token for the repository this script is running against"
    method_option "commit-spec", default: "main", desc: "the commit-ish used to determine the diff."
    method_option "auto-correct", type: :boolean, default: false, desc: "runs RuboCop with auto-correct option (deprecated)"
    method_option "autocorrect", type: :boolean, default: false, desc: "runs RuboCop with autocorrect option"
    method_option "autocorrect-all", type: :boolean, default: false, desc: "runs RuboCop with autocorrect-all option"
    method_option "junit_report", type: :string, default: nil, desc: "runs RuboCop with junit formatter option"
    method_option "json", type: :string, default: nil, desc: "Output results as JSON format to the provided file"

    def diff_enforced_github
      invoke :diff_github, nil, options
    end

    desc "diff", "run RuboCop on the current diff"
    method_option "commit-spec", default: "origin/main", desc: "the commit used to determine the diff."
    method_option "only", desc: "run only specified cop(s) and/or cops in the specified departments"
    method_option "auto-correct", type: :boolean, default: false, desc: "runs RuboCop with auto-correct option (deprecated)"
    method_option "autocorrect", type: :boolean, default: false, desc: "runs RuboCop with autocorrect option"
    method_option "autocorrect-all", type: :boolean, default: false, desc: "runs RuboCop with autocorrect-all option"
    method_option "ignore", type: :boolean, default: true, desc: "ignores files specified in #{options[:diffignore_file]}"
    method_option "added-only", type: :boolean, default: false, desc: "runs RuboCop only on files that have been added (not on files that have been modified)"
    method_option "exit", type: :boolean, default: true, desc: "disable to prevent task from exiting. Used by other Thor tasks when invoking this task, to prevent parent task from exiting"

    def diff
      puts "Running on files changed relative to '#{options[:"commit-spec"]}' (specify using the 'commit-spec' option)"
      diff_filter = options[:"added-only"] ? "A" : "d"
      diff_base = capture_std_out("git merge-base HEAD #{options[:"commit-spec"]}").chomp

      files, diff_status = Open3.capture2("git diff #{diff_base} --diff-filter=#{diff_filter} --name-only | grep \"\\.rb$\"")

      if diff_status != 0
        if options[:exit]
          puts "There are no rb files present in diff. Exiting."
          exit 0
        else
          puts "There are no rb files present in diff."
          return true
        end
      end

      if options[:ignore] && File.exist?(options[:diffignore_file]) && !File.empty?(options[:diffignore_file])
        files, non_ignored_diff_status = Open3.capture2("grep -v -f #{options[:diffignore_file]}", stdin_data: files)

        if non_ignored_diff_status != 0
          if options[:exit]
            puts "There are no non-ignored rb files present in diff. Exiting."
            exit 0
          else
            puts "There are no non-ignored rb files present in diff."
            return true
          end
        end
      end

      no_violations_detected = invoke :rubocop, [multi_line_to_single_line(files)], options

      exit 1 unless no_violations_detected
      return true unless options[:exit]
      exit 0
    end

    desc "diff_github", "run RuboCop on the current diff (using GitHub to find the files changes)"
    method_option "github-authorization-token", desc: "a GitHub authorization token for the repository this script is running against"
    method_option "commit-spec", default: "main", desc: "the commit-ish used to determine the diff."
    method_option "only", desc: "run only specified cop(s) and/or cops in the specified departments"
    method_option "auto-correct", type: :boolean, default: false, desc: "runs RuboCop with auto-correct option (deprecated)"
    method_option "autocorrect", type: :boolean, default: false, desc: "runs RuboCop with autocorrect option"
    method_option "autocorrect-all", type: :boolean, default: false, desc: "runs RuboCop with autocorrect-all option"
    method_option "ignore", type: :boolean, default: true, desc: "ignores files specified in #{options[:diffignore_file]}"
    method_option "added-only", type: :boolean, default: false, desc: "runs RuboCop only on files that have been added (not on files that have been modified)"
    method_option "exit", type: :boolean, default: true, desc: "disable to prevent task from exiting. Used by other Thor tasks when invoking this task, to prevent parent task from exiting"

    def diff_github
      puts "Running on files changed relative to '#{options[:"commit-spec"]}' (specify using the 'commit-spec' option)"
      diff_head = capture_std_out("git rev-parse HEAD").chomp
      diff_base = options[:"commit-spec"]
      repository = capture_std_out("git remote get-url origin | sed 's/git@github.com://; s/.git//'").chomp

      uri = URI("https://api.github.com/repos/#{repository}/compare/#{diff_base}...#{diff_head}")
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/vnd.github+json"
      request["Authorization"] = "Bearer #{options[:"github-authorization-token"]}"
      request["X-GitHub-Api-Version"] = "2022-11-28"

      response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) { |http| http.request(request) }

      if response.code != "200"
        puts "Error fetching data from Github: #{response.code} -- #{response.body}"
        return true unless options[:exit]

        exit 0
      end

      commit_data = JSON.parse(response.body)

      diff_filter = options[:"added-only"] ? proc { |status| status == "added" } : proc { |status| status != "removed" }
      files = commit_data["files"]
        .filter { |file_data| diff_filter.call(file_data["status"]) }
        .map { |file_data| file_data["filename"] }
        .filter { |file_name| file_name.include?(".rb") }
        .join("\n")

      if files.empty?
        if options[:exit]
          puts "There are no rb files present in diff. Exiting."
          exit 0
        else
          puts "There are no rb files present in diff."
          return true
        end
      end

      if options[:ignore] && File.exist?(options[:diffignore_file]) && !File.empty?(options[:diffignore_file])
        files, non_ignored_diff_status = Open3.capture2("grep -v -f #{options[:diffignore_file]}", stdin_data: files)

        if non_ignored_diff_status != 0
          if options[:exit]
            puts "There are no non-ignored rb files present in diff. Exiting."
            exit 0
          else
            puts "There are no non-ignored rb files present in diff."
            return true
          end
        end
      end

      no_violations_detected = invoke :rubocop, [multi_line_to_single_line(files)], options

      exit 1 unless no_violations_detected
      return true unless options[:exit]

      exit 0
    end

    desc "rubocop", "run RuboCop on files provided"
    method_option "only", desc: "run only specified cop(s) and/or cops in the specified departments"
    method_option "auto-correct", type: :boolean, default: false, desc: "runs RuboCop with auto-correct option (deprecated)"
    method_option "autocorrect", type: :boolean, default: false, desc: "runs RuboCop with autocorrect option"
    method_option "autocorrect-all", type: :boolean, default: false, desc: "runs RuboCop with autocorrect-all option"

    def rubocop(files = nil)
      puts "Running all cops..."
      config_file = RUBOCOP_DEFAULT_CONFIG_FILE

      formatters = []
      formatters << "--format Nucop::Formatters::JUnitFormatter --out #{options[:junit_report]}" if options[:junit_report]
      formatters << "--format json --out #{options[:json]}" if options[:json]
      formatters << "--format progress" if formatters.any?

      command = [
        "bundle exec rubocop",
        "--no-server",
        "--parallel",
        rubocop_gem_requires.join(" "),
        formatters.join(" "),
        "--force-exclusion",
        "--config", config_file,
        pass_through_option(options, "auto-correct"),
        pass_through_option(options, "autocorrect"),
        pass_through_option(options, "autocorrect-all"),
        pass_through_flag(options, "only"),
        files
      ].join(" ")

      system(command)
    end

    desc "regen_backlog", "update the RuboCop backlog, disabling offending files and excluding all cops with over 500 violating files."
    method_option "exclude-limit", type: :numeric, default: 500, desc: "Limit files listed to this limit. Passed to RuboCop"

    def regen_backlog
      regenerate_rubocop_todos
    end

    desc "update_enforced", "update the enforced cops list with file with cops that no longer have violations"
    def update_enforced
      puts "This is a no-op. Enforced cops are not currently supported."
    end

    desc "modified_lines", "display RuboCop violations for ONLY modified lines"
    method_option "commit-spec", default: "main", desc: "the commit used to determine the diff."

    def modified_lines
      diff_files, diff_status = Open3.capture2("git diff #{options[:"commit-spec"]} --diff-filter=d --name-only | grep \"\\.rb$\"")

      exit 1 unless diff_status.exitstatus.zero?

      command = [
        "bundle exec rubocop",
        "--parallel",
        "--no-server",
        "--format Nucop::Formatters::GitDiffFormatter",
        "--config #{RUBOCOP_DEFAULT_CONFIG_FILE}",
        multi_line_to_single_line(diff_files).to_s
      ].join(" ")

      # HACK: use ENVVAR to parameterize GitDiffFormatter
      system({ "RUBOCOP_COMMIT_SPEC" => options[:"commit-spec"] }, command)
    end

    desc "ready_for_promotion", "display the next n cops with the fewest offenses"
    method_option "n", type: :numeric, default: 1, desc: "number of cops to display"

    def ready_for_promotion
      puts "This is a no-op. Enforced cops are not currently supported."
    end

    private

    def capture_std_out(command, error_message = nil, stdin_data = nil)
      std_out, std_error, status = Open3.capture3(command, stdin_data: stdin_data)
      print_errors_and_exit(std_error, error_message) unless status.success?

      std_out
    end

    def print_errors_and_exit(std_error, message = "An error has occurred")
      warn message
      puts std_error
      puts "Exiting"
      exit 1
    end

    def multi_line_to_single_line(str)
      str.split(/\n+/).join(" ")
    end

    def pass_through_flag(options, option)
      pass_through_option(options, option, true)
    end

    def pass_through_option(options, option, is_flag_option = false)
      return nil unless options[option]
      "--#{option} #{options[option] if is_flag_option}"
    end

    def regenerate_rubocop_todos
      puts "Regenerating '#{options[:rubocop_todo_file]}'. Please be patient..."

      rubocop_options = [
        "--auto-gen-config",
        "--config #{RUBOCOP_DEFAULT_CONFIG_FILE}",
        "--exclude-limit #{options[:"exclude-limit"]}",
        "--no-server"
      ]

      rubocop_command = "DISABLE_SPRING=1 bundle exec rubocop #{rubocop_options.join(' ')} #{rubocop_gem_requires.join(' ')}"

      system(rubocop_command)

      # RuboCop wants to inherit from our todos (options[:rubocop_todo_file]) in our configuration file.
      # However, that means the next time we try to update our backlog, it will NOT include the violations
      # recorded as todo. For now, we ignore any changes in our config.
      system("git checkout #{RUBOCOP_DEFAULT_CONFIG_FILE}")
    end

    def rubocop_gem_requires
      Nucop::Helpers::RubocopGemDependencies.rubocop_gems.map { |rubocop_gem| "--require #{rubocop_gem}" }
    end
  end
end
