# frozen_string_literal: true

# Author: Usman Ahmad

require 'csv'
require 'colorize'
require 'date'
require 'logger'

# Calendar module for a simple calendar alongwith the facility to add/remove/
# delete and view events
module Cal
  DATE_FMT = '%Y-%m-%d'
  MONTH_FMT = '%Y-%m'

  # An Event class to hold name, detail and occuring date of an event
  class Event
    include Comparable

    attr_accessor :name, :detail, :date

    def initialize(event_name, event_detail, date = Date.today)
      @name = event_name
      @detail = event_detail
      @date = date
    end
  end

  # A module for easy printing for the 'Calendar' class
  module PrintableCalendar
    def print_monthly_calendar(date, column_width = 8)
      calendar_width = 7 * column_width

      monthly_events = monthly_events_dict(date)

      print_calendar_header(date, column_width, calendar_width)

      # add offset
      print ' ' * (column_width * (date.wday - 1))

      print_calendar_data(date, monthly_events, column_width)

      puts
      print_line(calendar_width)
      puts
    end

    def print_event(event, ind = nil)
      date_str = event.date.strftime('%B %d, %Y %A').blue
      event_head = "#{date_str} -- " + event.name.red
      event_head = (ind + 1).to_s + '. ' + event_head unless ind.nil?
      puts event_head

      puts "\t#{event.detail}".green
    end

    def print_events
      puts '*** Events ***'.red
      event_count = 0

      @events.each.with_index do |event, i|
        print_event(event, i)
        event_count += 1
      end

      puts "\tNo event to print..." if event_count.zero?

      @events
    end

    def print_monthly_events(date)
      month_name = get_month_name(date.month)
      monthly_events = monthly_events_arr(date.month, date.year)

      puts " *** Events for #{month_name}, #{date.year} ***".red
      event_count = 0

      monthly_events.each.with_index do |event, i|
        print_event(event, i)
        event_count += 1
      end

      puts "\tNo event to print..." if event_count.zero?

      monthly_events
    end

    private

    def print_line(width)
      puts '_' * width
    end

    def print_calendar_header(date, column_width, calendar_width)
      month_name = get_month_name(date.month)
      puts " *** Calendar for #{month_name}, #{date.year} ***".red
      print_line(calendar_width)
      days_arr = Date::DAYNAMES.map { |day| day[0...3] }
      days_arr.each { |day| print format("%-#{column_width}s", day).red }
      puts
      print_line(calendar_width)
    end

    def print_calendar_date_string(date, events, column_width)
      date_str = date.day.to_s
      date_str += "(#{events})" unless events.zero?
      date_str = format("%-#{column_width}s", date_str)

      date_str = date_str.green if Date.today == date

      if (date.wday % 7).zero?
        puts date_str
      else
        print date_str
      end
    end

    def print_calendar_data(date, monthly_events, column_width)
      month = date.month
      while date.month == month
        events = monthly_events[date.day].count
        print_calendar_date_string(date, events, column_width)

        date += 1
      end
    end

    def get_month_name(n_month)
      Date::MONTHNAMES[n_month]
    end
  end

  # This module helps the 'Calendar' class to have a csv file storage
  module PersistentCalendar
    DEFAULT_STORAGE_FILE = 'calendar.events'

    def initialize_storage_file
      if File.file? @storage_file
        load_storage_file
      else
        puts "The file '#{@storage_file}' was not present..."
        puts "The storage file '#{@storage_file}' will be created on addition of events..."
      end
    end

    def load_storage_file
      CSV.foreach(@storage_file, headers: true) do |row|
        date = Date.strptime(row[2], Cal::DATE_FMT)

        @events << Event.new(row[0], row[1], date)
      end
    rescue StandardError
      error_msg = "An error occured while reading the file '#{@storage_file}'"
      raise(StandardError, error_msg)
    end

    def write_file_header(file)
      file.write "Name,Details,Date\n"
    end

    def write_file_data(file, event)
      file.write "#{event.name},#{event.detail},#{event.date}\n"
    end

    def write_storage_file
      File.open(@storage_file, 'w') do |f|
        write_file_header(f)
        @events.each do |event|
          write_file_data(f, event)
        end
      end
    rescue StandardError
      error_msg = "An error occured while writing the file '#{@storage_file}'"
      raise(StandardError, error_msg)
    end
  end

  # Calendar class to manage events and view them in cli
  class Calendar
    include PrintableCalendar
    include PersistentCalendar

    attr_accessor :events, :storage_file # only for testing

    def initialize(storage_file = DEFAULT_STORAGE_FILE)
      @storage_file = storage_file

      @events = []
      initialize_storage_file
    end

    def add_event(name, detail, date)
      event = Event.new(name, detail, date)
      @events << event

      sort_and_write_storage_file

      event
    end

    def remove_event(event)
      @events.delete event

      write_storage_file
    end

    def edit_event(event, name, detail, date)
      return nil unless @events.include? event

      event.name = name
      event.detail = detail
      event.date = date

      sort_and_write_storage_file
      event
    end

    private

    def sort_and_write_storage_file
      @events = @events.sort { |event1, event2| event1.date <=> event2.date }

      write_storage_file
    end

    def monthly_events_arr(month, year)
      events = @events.filter do |event|
        event.date.month == month && event.date.year == year
      end

      events
    end

    def monthly_events_dict(start_date)
      events = {}
      month = start_date.month

      while start_date.month == month
        events[start_date.day] = events_on(start_date)
        start_date += 1
      end
      events
    end

    def events_on(date)
      @events.filter { |event| event.date == date }
    end
  end
end
