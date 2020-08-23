# frozen_string_literal: true

require_relative '../lib/clioper.rb'

describe CLIOperations, '#general_input_response' do
  context 'validation lambda checking for 1 or more digits' do
    validation_lambda = ->(str) { str =~ /\d+/ }

    prompt = 'Enter a number'
    invalid_input_msg = 'Invalid response. Please enter again.'

    it 'asks for input again and again until valid input is supplied and returns that number' do
      allow($stdin).to receive(:gets).and_return('abc', 'def', '123')

      response = CLIOperations.general_secure_input(prompt, invalid_input_msg, validation_lambda)
      puts "The response was '#{response}'"

      expect(response).to eq('123')
    end

    it 'returns nil if character for quiting is inputted' do
      allow($stdin).to receive(:gets).and_return(CLIOperations::QUIT_CHARACTER)

      response = CLIOperations.general_secure_input(prompt, invalid_input_msg, validation_lambda)

      puts
      expect(response).to be nil
    end
  end
end

describe CLIOperations, '#secure_ranged_integer_input' do
  context 'basic testing' do
    min = 10
    max = 50

    invalid_inputs = ['blah blah', '44453', '', '-1']

    valid_input1 = min.to_s
    valid_input2 = max.to_s
    valid_input_between = '20'

    it "asks for input again and again until valid input within the range of '#{min}' and '#{max}' is supplied" do
      allow($stdin).to receive(:gets).and_return(*invalid_inputs, valid_input1)
      response1 = CLIOperations.secure_ranged_integer_input(max, min)

      allow($stdin).to receive(:gets).and_return(valid_input2)
      response2 = CLIOperations.secure_ranged_integer_input(max, min)

      allow($stdin).to receive(:gets).and_return(valid_input_between)
      response3 = CLIOperations.secure_ranged_integer_input(max, min)

      puts

      expect(response1).to eq(valid_input1)
      expect(response2).to eq(valid_input2)
      expect(response3).to eq(valid_input_between)
    end
  end

  context "when 'max_value' is less than 'min_value'" do
    it 'raises error' do
      expect { CLIOperations.secure_ranged_integer_input(5, 10) }.to raise_error(StandardError, /max_value.*min_value/)
    end
  end

  context 'when exit character is entered' do
    it 'returns nil' do
      allow($stdin).to receive(:gets).and_return(CLIOperations::QUIT_CHARACTER)
      response = CLIOperations.secure_ranged_integer_input(20, 10)

      puts
      expect(response).to be nil
    end
  end
end
