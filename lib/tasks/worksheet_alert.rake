namespace :redmine do  
  namespace :worksheet do
    require 'active_record'
    desc "Generate all navigation menus"
    task all: :environment do
      cc = ActiveRecord::Base.establish_connection(
        :adapter  => "mysql2",
        :encoding => "utf8",
        :host     => "localhost",
        :pool => 5,
        :username => "root",
        :password => "root",
        :database => "redmine_corn_development"
      )
      time_entry_user = []
      user_all= []
      time_entry = TimeEntry.where(created_on: DateTime.now.yesterday.strftime('%Y-%m-%d')..DateTime.now.strftime('%Y-%m-%d')).uniq(:id)
      time_entry.each do |t|
        time_entry_user << t.user_id
      end
      users = User.where(:is_worksheet => true)
      users.each do |u|
        user_all << u.id
      end
      Mailer.worksheet_alert(25).deliver
    end
  end
end