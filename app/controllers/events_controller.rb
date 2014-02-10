# encoding: utf-8

#  Copyright (c) 2012-2013, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class EventsController < CrudController
  include YearBasedPaging

  self.nesting = Group

  self.remember_params += [:year]

  decorates :event, :events, :group

  prepend_before_filter :authenticate_person_from_token!
  # load group before authorization
  prepend_before_filter :parent

  before_render_form :load_sister_groups
  before_render_form :load_kinds

  def new
    assign_attributes
    entry.dates.build
    entry.init_questions
    respond_with(entry)
  end

  # list scope preload :groups, :kinds which we dont need
  def list_entries
    model_scope.
      where(type: params[:type]).
      order_by_date.
      preload_all_dates.
      uniq.
      in_year(year)
  end

  private


  def build_entry
    type = model_params && model_params[:type].presence
    type ||= 'Event'
    event = Event.find_event_type!(type).new
    event.groups << parent
    event
  end

  def assign_attributes
    entry.attributes = model_params.except(:type, :contact)
  end

  def group
    parent
  end

  def index_path
    typed_group_events_path(group, @event.class, returning: true)
  end


  private

  def load_sister_groups
    master = @event.groups.first
    @groups = master.self_and_sister_groups.reorder(:name)
    # union to include assigned deleted events
    @groups = (@groups | @event.groups) - [group]
  end

  def load_kinds
    if entry.kind_class
      @kinds = entry.kind_class.without_deleted
      @kinds << entry.kind if entry.kind && entry.kind.deleted?
    end
  end

  def typed_group_events_path(group, event_type, options = {})
    path = "#{event_type.type_name}_group_events_path"
    send(path, group, options)
  end

  # TODO: dead code?
  def type_name(event_type)
    if event_type == Event
      'simple'
    else
      event_type.name.demodulize.underscore
    end
  end
end
