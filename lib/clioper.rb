# frozen_string_literal: true

# Author: Usman Ahmad

# A class for easy handling of Command Line Interfaces
class CLIOperations
  DEF_INT_PROMPT = 'Please enter a value'
  # def initialize(options)
  #   @options = options
  # end

  def self.secure_option_input(options)
    options.each.with_index do |option, ind|
      puts "#{ind + 1}. #{option[0]}"
    end
    res = CLIOperations.secure_ranged_integer_input(options.length)

    # call the respective corresponding to the selected input

    options[res.to_i - 1][1].call unless res.nil?
    res
  end

  def integer_input_response
    @options.each.with_index do |option, i|
      puts "#{i + 1}. #{option}"
    end
    CLIOperations.get_integer_response(@options.length)
  end

  def self.general_secure_input(prompt, invalid_input_msg, validation_lambda)
    prompt += ' {! to quit}: '
    res = prompted_input(prompt)

    until res == '!' || validation_lambda.call(res)
      puts invalid_input_msg

      res = prompted_input(prompt)
    end

    return nil if res == '!'

    res
  end

  def self.prompted_input(prompt)
    print prompt
    $stdin.gets.chomp
  end

  def self.secure_ranged_integer_input(max_value, min_value = 1, input_prompt = DEF_INT_PROMPT)
    return nil if max_value < min_value

    response_msg = input_prompt + " (#{min_value} - #{max_value})"
    invalid_input_msg = 'Invalid input... Please try again...'
    validation_lambda = ->(int_str) { int_str =~ /^\d+$/ && int_str.to_i <= max_value && int_str.to_i >= min_value }

    general_secure_input(response_msg, invalid_input_msg, validation_lambda)
  end
end
