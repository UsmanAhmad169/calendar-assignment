# frozen_string_literal: true

require_relative '../lib/calendar'

describe Cal::Calendar, '#add_event' do
  before(:each) do
    @calendar = Cal::Calendar.new('testcasefile1')

    event1 = Cal::Event.new('An event', 'This is an event', Date.iso8601('2018-01-30'))
    event2 = Cal::Event.new('Another event', 'This is another event', Date.iso8601('2019-03-30'))
  end

  it 'should do something' do
    expect(@calendar.events).to eq([])
  end
end
