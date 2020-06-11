# encoding: utf-8

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class ServiceTokenAbility < AbilityDsl::Base

  include AbilityDsl::Constraints::Group

  on(ServiceToken) do
    permission(:admin).may(:manage).in_same_layer
  end

  private

  def group
    subject.layer
  end

end
