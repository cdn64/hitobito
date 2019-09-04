# encoding: utf-8

#  Copyright (c) 2012-2015, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Person::EventQueries

  attr_reader :person

  def initialize(person)
    @person = person
  end

  def pending_applications
    person.event_applications.
      merge(Event::Participation.pending).
      includes(event: [:groups]).
      joins(event: :dates).
      order('event_dates.start_at').
      uniq.tap do |applications|
      Event::PreloadAllDates.for(applications.collect(&:event))
    end
  end

  def with_cancelation_or_rejection
    person.events
          .upcoming
          .joins('LEFT JOIN event_applications ' \
                 'ON event_participations.application_id = event_applications.id')
          .where("event_participations.state = 'canceled' OR event_applications.rejected = ?", true)
          .uniq
  end

  def upcoming_events
    person.events.
      upcoming.
      merge(Event::Participation.active).
      uniq.
      includes(:groups).
      preload_all_dates.
      order_by_date
  end

  def alltime_participations
    person.event_participations.
      active.
      includes(:roles, event: [:dates, :groups]).
      uniq.
      order('event_dates.start_at DESC')
  end

end
