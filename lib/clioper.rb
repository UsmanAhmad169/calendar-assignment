# frozen_string_literal: true

# Author: Usman Ahmad

# A class for easy handling of Command Line Interfaces
class CLIOperations
  QUIT_CHARACTER = '!'
  DEF_INT_PROMPT = 'Please enter a value'

  def self.general_secure_input(prompt, invalid_input_msg, validation_lambda)
    prompt += " {#{QUIT_CHARACTER} to quit}: "
    res = prompted_input(prompt)

    until res == QUIT_CHARACTER || validation_lambda.call(res)
      puts invalid_input_msg

      res = prompted_input(prompt)
    end
    return nil if res == QUIT_CHARACTER

    res
  end

  def self.prompted_input(prompt)
    print prompt
    $stdin.gets.chomp
  end

  def self.secure_ranged_integer_input(max_value, min_value = 1, input_prompt = DEF_INT_PROMPT)
    raise(StandardError, "max_value (#{max_value}) is less than min_value (#{min_value})") if max_value < min_value

    response_msg = input_prompt + " (#{min_value} - #{max_value})"
    invalid_input_msg = 'Invalid input... Please try again...'
    validation_lambda = ->(int_str) { int_str =~ /^\d+$/ && (min_value..max_value).include?(int_str.to_i) }

    general_secure_input(response_msg, invalid_input_msg, validation_lambda)
  end

  def self.secure_option_input(options)
    options.each.with_index do |option, ind|
      puts "#{ind + 1}. #{option[0]}"
    end
    res = CLIOperations.secure_ranged_integer_input(options.length)

    # call the respective lambda function corresponding to the selected input

    return_values = nil
    unless res.nil?
      _, procedure, *procedure_args = options[res.to_i - 1]
      return_values = procedure.call(*procedure_args)
    end

    [res, return_values]
  end
end
