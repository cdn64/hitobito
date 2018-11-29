# encoding: utf-8

#  Copyright (c) 2012-2018, Schweizer Blasmusikverband. This file is part of
#  This file is part of hitobito and licensed under the Affero General Public
#  License version 3 or later. See the COPYING file at the top-level
#  directory or at https://github.com/hitobito/hitobito.


require 'spec_helper'


describe RoleListsController, js: true do

  subject { page }

  let(:group)   { groups(:top_group) }
  let!(:role1)  { Fabricate(Group::TopGroup::Member.name.to_sym, group: group) }
  let!(:role2)  { Fabricate(Group::TopGroup::Member.name.to_sym, group: group) }
  let!(:leader) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: group) }

  before do
    sign_in
    visit group_people_path(group_id: group.id)
  end

  it 'deletes all roles' do
    find(:css, "#ids_[value='#{role1.person.id}']").set(true)
    find(:css, "#ids_[value='#{role2.person.id}']").set(true)

    click_link('Rollen entfernen')
    click_button('Entfernen')

    is_expected.not_to have_content(role1.person.first_name)
    is_expected.not_to have_content(role2.person.first_name)
  end

  it 'deletes selected roles' do
    find(:css, "#ids_[value='#{role1.person.id}']").set(true)
    find(:css, "#ids_[value='#{role2.person.id}']").set(true)
    find(:css, "#ids_[value='#{leader.person.id}']").set(true)

    click_link('Rollen entfernen')

    find(:css,"input[name='role[types][Group::TopGroup::Member]']").set(false)
    click_button('Entfernen')

    is_expected.to     have_content(role1.person.first_name)
    is_expected.to     have_content(role2.person.first_name)
    is_expected.not_to have_content(leader.person.first_name)
  end

  it 'creates multiple roles' do
    find(:css, "#ids_[value='#{role1.person.id}']").set(true)
    find(:css, "#ids_[value='#{role2.person.id}']").set(true)

    click_link('Rolle hinzufügen')

    select('Leader', from: 'role_type')
    click_button('2 Rollen erstellen')

    is_expected.to have_content('2 Rollen wurden erstellt')
    is_expected.to have_css("tr#person_#{role1.person.id} td p", text: 'Leader')
    is_expected.to have_css("tr#person_#{role2.person.id} td p", text: 'Leader')
  end

  it 'moves multiple roles' do
    find(:css, "#ids_[value='#{role1.person.id}']").set(true)
    find(:css, "#ids_[value='#{role2.person.id}']").set(true)
    find(:css, "#ids_[value='#{leader.person.id}']").set(true)

    click_link('Rollen verschieben')

    select('Secretary', from: 'role_type')
    click_button('Weiter')

    find(:css,"input[name='role[types][Group::TopGroup::Leader]']").set(false)
    click_button('Rollen verschieben')

    is_expected.to have_content('3 Rollen wurden verschoben')
    is_expected.to have_css("tr#person_#{role1.person.id} td p", text: 'Secretary')
    is_expected.to have_css("tr#person_#{role2.person.id} td p", text: 'Secretary')
    is_expected.to have_css("tr#person_#{leader.person.id} td p", text: 'Secretary')

    is_expected.not_to have_css("tr#person_#{role1.person.id} td p", text: 'Member')
    is_expected.not_to have_css("tr#person_#{role2.person.id} td p", text: 'Member')
    is_expected.to     have_css("tr#person_#{leader.person.id} td p", text: 'Leader')
  end

end
