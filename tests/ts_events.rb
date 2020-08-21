# frozen_string_literal: true

require 'date'
require_relative '../lib/calendar'

describe Cal::Event, '#==' do
  # before(:each) do

  # end

  context 'attributes of both events are the same' do
    date = Date.iso8601('2020-01-20')
    event1 = Cal::Event.new('An event', 'This is an event', date)
    event2 = Cal::Event.new('An event', 'This is an event', date)

    it 'does not consider two events to be equal even if all their arguments are equal ' do
      expect(event1).to_not eq(event2)
    end

    it 'considers events to be equal only if they are referencing the same things' do
      event3 = event1
      expect(event3).to eq(event1)
    end
  end
end

describe Cal::Calendar, 'sort events array' do
  context 'non empty events array' do
    it 'returns an array sorted in ascending order' do
      event1 = Cal::Event.new('An event', 'This is an event', Date.iso8601('2018-01-30'))
      event2 = Cal::Event.new('Another event', 'This is another event', Date.iso8601('2019-03-30'))

      sorted_array = [event1, event2, event1].sort { |event_a, event_b| event_a.date <=> event_b.date }
      expect(sorted_array).to eq([event1, event1, event2])
    end
  end
end
