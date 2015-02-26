require 'test_helper'

class TC_testCommandFinder < Clean::Test::TestCase
  include TestHelper

  def setup
    @app = CLIApp.new
    [:status, :deployable, :some_command, :some_similar_command].each do |command|
      @app.commands[command] = GLI::Command.new(:names => command)
    end
  end

  def teardown
  end

  def test_unknown_command_name
    assert_raise(GLI::UnknownCommand) do
      GLI::CommandFinder.new(@app.commands, :default_command => :status).find_command(:unfindable_command)
    end
  end

  def test_no_command_name_without_default
    assert_raise(GLI::UnknownCommand) do
      GLI::CommandFinder.new(@app.commands).find_command(nil)
    end
  end

  def test_no_command_name_with_default
    actual = GLI::CommandFinder.new(@app.commands, :default_command => :status).find_command(nil)
    expected = @app.commands[:status]

    assert_equal(actual, expected)
  end

  def test_ambigous_command
    expected_error_message = "Ambiguous command 'some'. It matches some_command,some_similar_command"
    assert_raise_with_message(GLI::AmbiguousCommand, expected_error_message) do
      GLI::CommandFinder.new(@app.commands, :default_command => :status).find_command(:some)
    end
  end

  def test_partial_name_with_autocorrect_enabled
    actual = GLI::CommandFinder.new(@app.commands, :default_command => :status).find_command(:deploy)
    expected = @app.commands[:deployable]

    assert_equal(actual, expected)
  end

  # def test_partial_name_with_autocorrect_disabled
    # assert_raise(GLI::UnknownCommand) do
    #   try to find command via partial name
    # end
  # end
end
