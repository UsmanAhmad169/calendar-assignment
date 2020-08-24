# frozen_string_literal: true

# Author: Usman Ahmad

require 'date'

require_relative 'calendar'
require_relative 'clioper'

# A Command Line Interface for the 'Calendar' class
class CalendarCLI
  TEXT_VALIDATION_LAMBDA = ->(text) { text =~ /^\w+(\s\w+)*$/ }

  def initialize(calendar)
    @calendar = calendar
  end

  def menu
    options = [
      ['Print all events.', -> { print_all_events }],
      ['Print calendar of a month.', -> { print_month_calendar }],
      ['Print events of a month', -> { print_month_events }],
      ['Add an event.', -> { add_event }],
      ['Remove an event.', -> { remove_event }],
      ['Edit an event.', -> { edit_event }]
    ].freeze

    loop do
      res, = CLIOperations.secure_option_input(options)
      break if res.nil?

      puts
    end
  end

  def print_all_events
    @calendar.print_events
  end

  def print_month_calendar
    date = secure_input_month_year
    return nil if date.nil?

    @calendar.print_monthly_calendar(date)
  end

  def print_month_events
    date = secure_input_month_year
    return nil if date.nil?

    @calendar.print_monthly_events(date)
  end

  def add_event
    date = secure_input_date
    return nil if date.nil?

    name = secure_input_name
    return nil if name.nil?

    detail = secure_input_detail
    return nil if detail.nil?

    @calendar.add_event(name, detail, date)
  end

  def remove_event
    events = @calendar.print_events
    ind = CLIOperations.secure_ranged_integer_input(events.length)
    return nil if ind.nil?

    @calendar.remove_event(events[ind.to_i - 1])
  end

  def edit_event
    events = @calendar.print_events
    ind = CLIOperations.secure_ranged_integer_input(events.length)
    return nil if ind.nil?

    event = events[ind.to_i - 1]
    options = [
      ['Edit name', -> { edit_name(event) }],
      ['Edit detail', -> { edit_detail(event) }],
      ['Edit date', -> { edit_date(event) }]
    ].freeze
    CLIOperations.secure_option_input(options)
  end

  def edit_name(event)
    name = secure_input_name
    return nil if name.nil?

    @calendar.edit_event(event, name, event.detail, event.date)
  end

  def edit_detail(event)
    detail = secure_input_detail
    return nil if detail.nil?

    @calendar.edit_event(event, event.name, detail, event.date)
  end

  def edit_date(event)
    date = secure_input_date
    return nil if date.nil?

    @calendar.edit_event(event, event.name, event.detail, date)
  end

  private

  COMMON_YEAR_DAYS_IN_MONTH = [nil, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31].freeze

  def secure_input_month_year
    year = secure_input_year
    return nil if year.nil?

    month = secure_input_month
    return nil if month.nil?

    Date.strptime("#{year}-#{month}", Cal::MONTH_FMT)
  end

  def secure_input_date
    year = secure_input_year
    return nil if year.nil?

    month = secure_input_month
    return nil if month.nil?

    day = secure_input_day(month, year)
    return nil if day.nil?

    Date.strptime("#{year}-#{month}-#{day}", Cal::DATE_FMT)
  end

  def secure_input_year
    CLIOperations.secure_ranged_integer_input(3000, 1900, 'Enter the year')
  end

  def secure_input_month
    CLIOperations.secure_ranged_integer_input(12, 1, 'Enter the month')
  end

  def secure_input_day(month, year)
    max_days = days_in_month(month.to_i, year.to_i)

    CLIOperations.secure_ranged_integer_input(max_days, 1, 'Enter the day')
  end

  def secure_input_name
    CLIOperations.general_secure_input('Enter event name', 'Invalid Input', TEXT_VALIDATION_LAMBDA)
  end

  def secure_input_detail
    CLIOperations.general_secure_input('Enter event detail', 'Invalid Input', TEXT_VALIDATION_LAMBDA)
  end

  def days_in_month(month, year)
    return 29 if month == 2 && Date.gregorian_leap?(year)

    COMMON_YEAR_DAYS_IN_MONTH[month]
  end
end

if __FILE__ == $PROGRAM_NAME
  calendar = nil

  begin
    calendar = Cal::Calendar.new
  rescue StandardError => e
    puts e
  end

  unless calendar.nil?
    cli = CalendarCLI.new(calendar)
    cli.menu
  end
end
