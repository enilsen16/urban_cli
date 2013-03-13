require "test_helper"
require "open-uri"
require "socket"
require "shellwords"

class CLITest < MiniTest::Unit::TestCase

  def run_program(args)
    @program.run(Shellwords.shellwords(args))
  end

  def setup
    @program = Urban::CLI.new
  end

  class CLIArgumentParsingTest < CLITest

    def assert_flag_is_set(name)
      ["-#{name.chars.first}", "--#{name}"].each do |args|
        options = @program.send(:parse, [args])
        assert options.send(name)
      end
    end

    def test_defaults
      options = @program.send(:parse, [])
      refute options.help
      refute options.version
      refute options.random
      refute options.all
      assert_empty options.phrase
    end

    def test_phrase
      options = @program.send :parse, ["foo bar"]
      assert_equal "foo bar", options.phrase
    end

    def test_help_flag
      assert_flag_is_set "help"
    end

    def test_version_flag
      assert_flag_is_set "version"
    end

    def test_random_flag
      assert_flag_is_set "random"
    end

    def test_all_flag
      assert_flag_is_set "all"
    end

    def test_url_flag
      assert_flag_is_set "url"
    end
  end

  class CLIRunnerStandardOutputTest < CLITest


    def setup
      super
      @dictionary = MiniTest::Mock.new
    end

    def test_help_flag_prints_help
      help_screen = load_fixture "screens/help.txt"
      assert_output(help_screen) { @program.run([]) }
    end

    def test_version_flag_prints_version
      version_screen = "Urban #{Urban::VERSION} (c) Thomas Miller\n"
      assert_output(version_screen) { run_program "--version" }
    end

    def test_random_flag_prints_single_definition
      @program.dictionary = @dictionary.expect(:random, TEST_ENTRY)
      single_definition = load_fixture "screens/definition.txt"

      assert_output(single_definition) { run_program "--random" }
      @dictionary.verify
    end

    def test_phrase_prints_single_definition
      @program.dictionary = @dictionary.expect(:search, TEST_ENTRY, ["impromptu"])
      single_definition = load_fixture "screens/definition.txt"

      assert_output(single_definition) { run_program "impromptu" }
      @dictionary.verify
    end

    def test_random_and_all_flag_prints_multiple_definitions
      @program.dictionary = @dictionary.expect(:random, TEST_ENTRY)
      multiple_definitions = load_fixture "screens/definitions.txt"

      assert_output(multiple_definitions) { run_program "--all --random" }
      @dictionary.verify
    end

    def test_phrase_and_all_flag_prints_multiple_definitions
      @program.dictionary = @dictionary.expect(:search, TEST_ENTRY, ["impromptu"])
      multiple_definitions = load_fixture "screens/definitions.txt"

      assert_output(multiple_definitions) { run_program "--all impromptu" }
      @dictionary.verify
    end

    def test_random_and_url_flag_prints_definition_with_url
      @program.dictionary = @dictionary.expect(:random, TEST_ENTRY)
      definition_with_url = load_fixture "screens/definition_with_url.txt"

      assert_output(definition_with_url) { run_program "--url --random" }
      @dictionary.verify
    end

    def test_phrase_and_url_flag_prints_definition_with_url
      @program.dictionary = @dictionary.expect(:search, TEST_ENTRY, ["impromptu"])
      definition_with_url = load_fixture "screens/definition_with_url.txt"

      assert_output(definition_with_url) { run_program "--url impromptu" }
      @dictionary.verify
    end

    def test_list_flag_prints_deprecation_warning
      expected = /WARNING: --list and -l are deprecated please use --all or -a instead/
      @program.dictionary = @dictionary.expect(:search, TEST_ENTRY, ["impromptu"])
      @program.dictionary = @dictionary.expect(:random, TEST_ENTRY)
      stdout, stederr = capture_io { run_program "--list impromptu" }
      assert_match expected, stdout
      stdout, stederr  = capture_io { @program.run(Shellwords.shellwords("-rl")) }
      assert_match expected, stdout
    end
  end

  class CLIRunnerErrorOutputTest < CLITest

    def setup
      super
    end

    def test_search_missing_phrase_prints_error
      dictionary = MiniTest::Mock.new
      @program.dictionary = dictionary.expect(:search, EMPTY_ENTRY, ["gubble"])
      missing_phrase_error = load_fixture "screens/missing_phrase_error.txt"

      assert_output(nil, missing_phrase_error) { run_program("gubble") }
      dictionary.verify
    end


    def test_search_with_no_internet_prints_error
      dictionary = (Object.new).extend Stub
      dictionary.stub(:search) { |phrase| raise SocketError }
      no_internet_error = load_fixture "screens/no_internet_error.txt"

      @program.dictionary = dictionary
      assert_output(nil, no_internet_error) { run_program("gubble") }
    end

    def test_invalid_option_prints_help
      invalid_option_error = load_fixture "screens/invalid_option_error.txt"
      assert_output(nil, invalid_option_error) { run_program("-b") }
    end
  end
end
