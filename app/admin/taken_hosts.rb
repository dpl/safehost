ActiveAdmin.register Host, as: 'Taken Host' do
  includes :user
  
  permit_params :user_id, :address, :postal_code, :city, :country, :optimal_no_guests, :max_sleeps, :max_duration, :sleep_conditions, :which_guests, :which_hosts, :description, :languages, :other_comments, :available, :guest_name, :guest_data, :pickup_data, :guest_end_date
  
  controller do
    helper HostsHelper
    #before_action only: :index do
      #@per_page = 3 if UserPrivilege.get_scope_of_privilege(current_user, 'match_hosts_in_city').nil?
    #end

    def scoped_collection
      scope = UserPrivilege.get_scope_of_privilege(current_user, 'match_hosts_in_city')
      if scope == 'any' or scope.nil?
        Host.taken
      else # any specific scope
        Host.taken.where(city: scope)
      end
    end
  end
  
  filter :optimal_no_guests
  filter :max_duration
  filter :which_guests_contains, label: proc{I18n.t("admin.guest_includes")}, as: :select, collection: -> {t_for_select(GUEST_TYPES, "host.person_type")}
  filter :which_hosts_contains, label: proc{I18n.t("admin.host_includes")}, as: :select, collection: -> {t_for_select(HOST_TYPES, "host.person_type")}
  filter :languages_contains, label: proc{I18n.t("admin.languages_include")}, as: :select, collection: ["Deutsch", "English", "русский", "украї́нська", "Français", "Español", "Polski", "Misc Slavic", "Other", "no_common"]
  filter :sleep_conditions_contains, label: proc{I18n.t("admin.sleep_includes")}, as: :select, collection: -> {t_for_select(SLEEP_CONDITIONS, "host.sleep_cond")}
  filter :city
  filter :personal_name
  filter :family_name
  filter :user_mobile
  filter :created_at

  # quick filter by guest type
  scope :all, group: :hosting
  scope(proc {I18n.t("host.person_type.women")}, :women, group: :hosting)
  scope(proc {I18n.t("host.person_type.xmen")}, :men, group: :hosting)
  scope(proc {I18n.t("host.person_type.couple")}, :couple, group: :hosting)
  scope(proc {I18n.t("host.person_type.babies")}, :babies, group: :hosting)
  scope(proc {I18n.t("host.person_type.dogs")}, :dogs, group: :hosting)
  scope(proc {I18n.t("host.person_type.cats")}, :cats, group: :hosting)
  scope(">4", group: :hosting) { |scope| scope.where("optimal_no_guests > 4") }

  index title: proc{I18n.t("admin.taken_hosts")} do

    selectable_column
    column 'Name', sortable: :family_name do |host|
      s = raw(availability_state_icon(host))
      s += host.user.name
    end
    column :city
    column I18n.t("admin.opt_guests"), :optimal_no_guests
    column I18n.t("admin.max_guests"), :max_sleeps
    column I18n.t("admin.max_nights"), :max_duration
    column :which_guests
    column :which_hosts
    column :languages
    column :mobile do |host|
      host.user.mobile.to_s + " - " + host.user.contact_time.to_s
    end
    column :created_at
    actions
  end
  
  show  do
    panel I18n.t("admin.contact_data") do
      para taken_host.user.name
      para taken_host.user.email
      para taken_host.user.mobile 
      para "Host is: #{taken_host.which_hosts}"
    end
    default_main_content
  end
  
end
