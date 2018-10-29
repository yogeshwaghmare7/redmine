# encoding: utf-8
#
# Redmine - project management software
# Copyright (C) 2006-2017  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

module TimelogHelper
  include ApplicationHelper

  # Returns a collection of activities for a select field.  time_entry
  # is optional and will be used to check if the selected TimeEntryActivity
  # is active.
  def activity_collection_for_select_options(time_entry=nil, project=nil)
    project ||= time_entry.try(:project)
    project ||= @project
    if project.nil?
      activities = TimeEntryActivity.shared.active
    else
      activities = project.activities
    end

    collection = []
    if time_entry && time_entry.activity && !time_entry.activity.active?
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ]
    else
      collection << [ "--- #{l(:actionview_instancetag_blank_option)} ---", '' ] unless activities.detect(&:is_default)
    end
    activities.each { |a| collection << [a.name, a.id] }
    collection
  end

  def select_hours(data, criteria, value)
    if value.to_s.empty?
      data.select {|row| row[criteria].blank? }
    else
      data.select {|row| row[criteria].to_s == value.to_s}
    end
  end

  def sum_hours(data)
    hours = 0
    cc = []
    sum = 0
    data.each do |row|
      sum += row['hours'].to_f
      estimated_hours = TimeEntry.where(:user_id => row['user']).pluck(:hours, :id)
      estimated_hours.each do |b|
        hours = hours + b[0]# if !b.hours.nil?
        cc << b[1]
      end
    end
    return sum, cc
  end

  def days_in_year(year)
    d = Date.new(year, 1, 1)
    # See if the year is a leap year.
    if d.leap?
      return 366
    else
      return 365
    end
  end

  def days_in_month(year, month)
    Date.new(year, month, -1).day
  end


  
  def user_estimated_hours(data, criteria, value)
    puts "SSSSSSSSSSS-------#{value[0]}--------SSSSSSSS999999999999999(((((#{value[0].split('-')[1].to_i})))))))))SSSSSSSSSSS-------------#{(criteria == "month" && value.kind_of?(Array) && value.length == 1)} -------1234567890------- #{days_in_month(value[0].split('-')[0].to_i,value[0].split('-')[1].to_i).inspect}"
    hours = 0
    if (criteria == "month" && value.kind_of?(Array) && value.length == 1)
      start_date = DateTime.parse(value[0] += "-01 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
      c = days_in_month(value[0].split('-')[0].to_i,value[0].split('-')[1].to_i)
      end_date = DateTime.parse(value[0] += "-#{c.to_i} 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
      puts "SSSSSSSffffffffffffffffff111222222222222222fffffffffffffSSSSSFFFFFF111111111111FFFFFFBBBBBBBBBBBBBBBBBBB#{end_date.inspect}"
    elsif criteria == "month" && value.kind_of?(Array)
      #start_date = DateTime.parse(value[0] += '-1 00:00:00').strftime("%Y-%m-%d %H:%M:%S").to_datetime
      #cc = days_in_month(value[-1].split('-')[0].to_i,value[-1].split('-')[1].to_i)
      #end_date = DateTime.parse(value[-1] += "-#{cc} 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
    

    elsif criteria == "year" && value.kind_of?(Array)
      start_date = DateTime.parse(value[0] += "-01-01 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
      end_date =DateTime.parse(value[-1] += "-12-31 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
   
    end
      us = []
      data.each do |d|
        if (d['user'] && d['project'] && d['issue']).present?
          estimated_hours = Issue.where(:id=> d['issue'],:created_on => start_date..end_date)
          if estimated_hours.present? 
            estimated_hours.each do |b|
              hours = hours + b.estimated_hours if !b.estimated_hours.nil?
              us << b.id
            end
            return number_with_precision(hours, :precision => 2), us 
          else
            return hours
          end
        elsif (d['user'] && d['project']).present?
          estimated_hours = Issue.where(:project_id => d['project'], :assigned_to_id => d['user'],:created_on=> start_date..end_date)
          if estimated_hours.present? 
            estimated_hours.each do |b|
              hours = hours + b.estimated_hours if !b.estimated_hours.nil?
              us << b.id
            end
            return number_with_precision(hours, :precision => 2),us
          else
            return hours
          end
        elsif (d['user'] && d['issue']).present?
          estimated_hours = Issue.where(:id => d['issue'], :assigned_to_id => d['user'],:created_on=> start_date..end_date)
          if estimated_hours.present? 
            estimated_hours.each do |b|
              hours = hours + b.estimated_hours if !b.estimated_hours.nil?
              us << b.id
            end
            return number_with_precision(hours, :precision => 2),us 
          else
            return hours
          end
        elsif (d['project'] && d['issue']).present?
          estimated_hours = Issue.where(:project_id => d['project'], :id => d['issue'],:created_on=> start_date..end_date)
          if estimated_hours.present? 
            estimated_hours.each do |b|
              hours = hours + b.estimated_hours if !b.estimated_hours.nil?
              us << b.id
            end
            return number_with_precision(hours, :precision => 2), us
          else
            return hours
          end
        elsif (d['user']).present?
        estimated_hours = Issue.where(:assigned_to_id=> d['user'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?# and b.created_on.to_date in 
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us
        else
          return hours
        end
      elsif (d['project']).present?
        estimated_hours = Issue.where(:project_id => d['project'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2),us 
        else
          return hours
        end
      elsif (d['issue']).present?                      
        estimated_hours = Issue.where(:id => d['issue'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us
        else
          return hours
        end
      end
    end
  end


  def user_period_estimated_hours(data, criteria, value)
    if criteria == "month"
      start_date = DateTime.parse(value += '-1').strftime("%Y-%m-%d %H:%M:%S").to_datetime
      cc = days_in_month(start_date.strftime("%Y").to_i, start_date.strftime("%m").to_i)
      end_date = start_date.to_date + cc
    elsif criteria == "year"
      start_date = DateTime.parse(value += "-01-01 00:00:00").strftime("%Y-%m-%d %H:%M:%S").to_datetime
      end_date = start_date.to_date+ days_in_year(value.to_i)
    end

    hours = 0
    us = []
    data.each do |d|
      if (d['user'] && d['project'] && d['issue']).present?
        estimated_hours = Issue.where(:id=> d['issue'] ,:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us 
        else
          return hours
        end
      elsif (d['user'] && d['project']).present?
        estimated_hours = Issue.where(:project_id => d['project'], :assigned_to_id => d['user'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2),us
        else
          return hours
        end
      elsif (d['user'] && d['issue']).present?
        estimated_hours = Issue.where(:id => d['issue'], :assigned_to_id => d['user'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2),us 
        else
          return hours
        end
      elsif (d['project'] && d['issue']).present?
        estimated_hours = Issue.where(:project_id => d['project'], :id => d['issue'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us
        else
          return hours
        end
      elsif (d['user']).present?
        estimated_hours = Issue.where(:assigned_to_id=> d['user'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?# and b.created_on.to_date in 
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us
        else
          return hours
        end
      elsif (d['project']).present?
        estimated_hours = Issue.where(:project_id => d['project'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2),us 
        else
          return hours
        end
      elsif (d['issue']).present?                      
        estimated_hours = Issue.where(:id => d['issue'],:created_on=> start_date..end_date)
        if estimated_hours.present? 
          estimated_hours.each do |b|
            hours = hours + b.estimated_hours if !b.estimated_hours.nil?
            us << b.id
          end
          return number_with_precision(hours, :precision => 2), us
        else
          return hours
        end
      end
    end
  end
  def project_name(id)
    project = Project.find_by(:id => id)
    return project.name if project.present?
  end

  def task_status(id)
    task = IssueStatus.find_by(:id => id)
    return task.name if task.present?
  end

  def assignee_name(id)
    user = User.find_by(:id => id)
    fullname = (user.firstname )+ " " +( user.lastname)
    return fullname if user.present?
  end


  def issue_tracker(id)
    tracker = Tracker.find_by(:id => id)
    return tracker.name if tracker.present?
  end

  def format_criteria_value(criteria_options, value)
    if value.blank?
      "[#{l(:label_none)}]"
    elsif k = criteria_options[:klass]
      obj = k.find_by_id(value.to_i)
      if obj.is_a?(Issue)
        obj.visible? ? "#{obj.tracker} ##{obj.id}: #{obj.subject}" : "##{obj.id}"
      else
        obj
      end
    elsif cf = criteria_options[:custom_field]
      format_value(value, cf)
    else
      value.to_s
    end
  end

  def report_to_csv(report)
    Redmine::Export::CSV.generate do |csv|
      # Column headers
      headers = report.criteria.collect {|criteria| l(report.available_criteria[criteria][:label]) }
      headers += report.periods
      headers << l(:label_total_time)
      csv << headers
      # Content
      report_criteria_to_csv(csv, report.available_criteria, report.columns, report.criteria, report.periods, report.hours)
      # Total row
      str_total = l(:label_total_time)
      row = [ str_total ] + [''] * (report.criteria.size - 1)
      total = 0
      report.periods.each do |period|
        sum = sum_hours(select_hours(report.hours, report.columns, period.to_s))
        total += sum
        row << (sum > 0 ? sum : '')
      end
      row << total
      csv << row
    end
  end

  def report_criteria_to_csv(csv, available_criteria, columns, criteria, periods, hours, level=0)
    hours.collect {|h| h[criteria[level]].to_s}.uniq.each do |value|
      hours_for_value = select_hours(hours, criteria[level], value)
      next if hours_for_value.empty?
      row = [''] * level
      row << format_criteria_value(available_criteria[criteria[level]], value).to_s
      row += [''] * (criteria.length - level - 1)
      total = 0
      periods.each do |period|
        sum = sum_hours(select_hours(hours_for_value, columns, period.to_s))
        total += sum
        row << (sum > 0 ? sum : '')
      end
      row << total
      csv << row
      if criteria.length > level + 1
        report_criteria_to_csv(csv, available_criteria, columns, criteria, periods, hours_for_value, level + 1)
      end
    end
  end
end
