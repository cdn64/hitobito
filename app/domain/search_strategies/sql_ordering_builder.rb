# encoding: utf-8

#  Copyright (c) 2017, Hitobito AG. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module SearchStrategies
  class SqlOrderingBuilder

    def initialize(scope, user)
      @scope = scope
      @user = user
    end

    def order_clause
      return if @scope != 'Person'

      [
        'CASE WHEN people.id IN ? THEN 1 WHEN people.id IN ? THEN 2 ELSE 3 END ASC',
        people_in_own_groups,
        people_in_own_groups_hierarchies
      ]
    end

    private

    def people_in_own_groups
      @people_in_own_groups ||= Role.where(group_id: user.group_ids).pluck(:person_id)
    end

    def people_in_own_groups_hierarchies
      @people_in_own_groups_hierarchies ||=
        Role.where(group_id: user.groups_hierarchy_ids - user.group_ids).pluck(:person_id)
    end

  end
end
