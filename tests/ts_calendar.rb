# frozen_string_literal: true

# Author: Usman Ahmad

require_relative '../lib/calendar'

describe Cal::Calendar, '#add_event' do
  before(:each) do
    @calendar = Cal::Calendar.new('testcasefile1')

    # @event1 = Cal::Event.new('An event', 'This is an event', Date.iso8601('2018-01-30'))
    # @event2 = Cal::Event.new('Another event', 'This is another event', Date.iso8601('2019-03-30'))
  end

  after(:each) do
    File.delete @calendar.storage_file
  end

  it "creates a new Event and adds it to 'events' array; also it creates the storage file if not present" do
    returned_event = @calendar.add_event('An event', 'This is an event', Date.iso8601('2018-01-30'))

    expect(@calendar.events[-1]).to eq(returned_event)
    expect(File.file?(@calendar.storage_file)).to eq(true)
  end
end

describe Cal::Calendar, '#remove_event' do
  before(:each) do
    @calendar = Cal::Calendar.new('testcasefile1')

    @calendar.add_event('An event', 'This is an event', Date.iso8601('2018-01-30'))
    @event_to_be_removed = @calendar.add_event('Another event', 'This is another event', Date.iso8601('2019-03-30'))
  end

  after(:each) do
    File.delete @calendar.storage_file
  end

  it "removes the event from 'events' list and writes to the storage file" do
    @calendar.remove_event(@event_to_be_removed)

    expect(@calendar.events.find_index(@event_to_be_removed)).to eq(nil)
  end
end

describe Cal::Calendar, '#edit_event' do
  before(:each) do
    @calendar = Cal::Calendar.new('testcasefile1')

    @calendar.add_event('An event', 'This is an event', Date.iso8601('2018-01-30'))
    @event_to_be_edited = @calendar.add_event('Another event', 'This is another event', Date.iso8601('2019-03-30'))
  end

  after(:each) do
    File.delete @calendar.storage_file
  end

  it "gets the event from 'events' array, edits it and sorts the array and writes result to the storage file" do
    new_name = 'Some Event'
    new_detail = 'Some Detail'
    new_date = Date.iso8601('2020-08-21')

    edit_return = @calendar.edit_event(@event_to_be_edited, new_name, new_detail, new_date)

    expect(@calendar.events[-1]).to eq(@event_to_be_edited)
    expect(@event_to_be_edited).to eq(edit_return)
    expect(@event_to_be_edited.name).to eq(new_name)
    expect(@event_to_be_edited.detail).to eq(new_detail)
    expect(@event_to_be_edited.date).to eq(new_date)
  end

  it 'returns nil if the event to be edited was not found' do
    new_name = 'Some Event'
    new_detail = 'Some Detail'
    new_date = Date.iso8601('2020-08-21')

    event_with_same_attributes = Cal::Event.new('An event', 'This is an event', Date.iso8601('2018-01-30'))
    edit_return = @calendar.edit_event(event_with_same_attributes, new_name, new_detail, new_date)

    expect(edit_return).to eq(nil)
  end
end
