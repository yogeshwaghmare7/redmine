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

class TimelogController < ApplicationController
  menu_item :time_entries

  before_action :find_time_entry, :only => [:show, :edit, :update]
  before_action :check_editability, :only => [:edit, :update]
  before_action :find_time_entries, :only => [:bulk_edit, :bulk_update, :destroy]
  before_action :authorize, :only => [:show, :edit, :update, :bulk_edit, :bulk_update, :destroy]

  before_action :find_optional_issue, :only => [:new, :create, :worksheet_entry]
  before_action :find_optional_project, :only => [:index, :report]
  before_action :authorize_global, :only => [:new, :create, :index, :report]

  accept_rss_auth :index
  accept_api_auth :index, :show, :create, :update, :destroy

  rescue_from Query::StatementInvalid, :with => :query_statement_invalid

  helper :issues
  include TimelogHelper
  helper :custom_fields
  include CustomFieldsHelper
  helper :queries
  include QueriesHelper

  def index
    retrieve_time_entry_query
    scope = time_entry_scope.
      preload(:issue => [:project, :tracker, :status, :assigned_to, :priority]).
      preload(:project, :user)

    respond_to do |format|
      format.html {
        @entry_count = scope.count
        @entry_pages = Paginator.new @entry_count, per_page_option, params['page']
        @entries = scope.offset(@entry_pages.offset).limit(@entry_pages.per_page).to_a

        render :layout => !request.xhr?
      }
      format.api  {
        @entry_count = scope.count
        @offset, @limit = api_offset_and_limit
        @entries = scope.offset(@offset).limit(@limit).preload(:custom_values => :custom_field).to_a
      }
      format.atom {
        entries = scope.limit(Setting.feeds_limit.to_i).reorder("#{TimeEntry.table_name}.created_on DESC").to_a
        render_feed(entries, :title => l(:label_spent_time))
      }
      format.csv {
        # Export all entries
        @entries = scope.to_a
        send_data(query_to_csv(@entries, @query, params), :type => 'text/csv; header=present', :filename => 'timelog.csv')
      }
    end
  end


  def details
    if params[:format].present?
      issue = params[:format].split("/")
      @issues = Issue.where(:id => issue).order(created_on: :desc)

      render :layout => !request.xhr?
    end
  end

  def timelog_details
    puts "SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSDDDDDDD#{params.inspect}"
    if params[:format].present?
      issue = params[:format].split("/")
      @issues = TimeEntry.where(:id => issue).order(created_on: :desc)

      render :layout => !request.xhr?
    end
  end
#2372444000

  def report
    retrieve_time_entry_query
    scope = time_entry_scope
   # h= TimeEntry.find_by_sql("SELECT issues.id, (SELECT name FROM projects WHERE id=issues.project_id) as 'Project', issues.subject as 'Name', issues.created_on as 'Created',
#(SELECT name FROM trackers WHERE id=issues.tracker_id) as 'Type', issues.estimated_hours as 'Estimated',
#(SELECT login FROM users WHERE id=assigned_to_id) as 'Assigned', sum(hours) as 'Spent', t.Totalhours
#FROM `time_entries` te RIGHT JOIN issues ON issues.id=te.issue_id
#inner join (SELECT SUM(hours) Totalhours, issue_id FROM time_entries group by issue_id) t on t.issue_id=issues.id
#WHERE user_id=issues.assigned_to_id
#GROUP BY issues.id
#{}")

#    puts "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO#{h.inspect}"
    @report = Redmine::Helpers::TimeReport.new(@project, @issue, params[:criteria], params[:columns], scope)

    respond_to do |format|
      format.html { render :layout => !request.xhr? }
      format.csv  { send_data(report_to_csv(@report), :type => 'text/csv; header=present', :filename => 'timelog.csv') }
    end
  end

  def worksheet_entry
    time_entry_user = []
    time_entry = TimeEntry.where(created_on: DateTime.now.yesterday.strftime('%Y-%m-%d 00:00:00')..DateTime.now.strftime('%Y-%m-%d %H:%M:%S')).uniq(:user_id)
    time_entry.each do |t|
      time_entry_user << t.user_id
    end
    users = User.where.not(:id => time_entry_user, :status => [0,3])
    users.each do |u|
      time_entriess = Hash.new
      time_entriess["issue_id"] = 623
      time_entriess["spent_on"] = DateTime.now.yesterday.strftime('%Y-%m-%d')
      time_entriess["hours"] = 0.0
      time_entriess["comments"] = "Not fill time entry on "
      time_entriess["activity_id"] = 16
      @entry = TimeEntry.new(:project => @project, :issue => @issue, :user => u, :spent_on => u.today)
      @entry.safe_attributes = time_entriess
      @entry.save
    end
    redirect_to time_entries_path
  end

  def show
    respond_to do |format|
      # TODO: Implement html response
      format.html { head 406 }
      format.api
    end
  end

  def new
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.safe_attributes = params[:time_entry]
  end

  def create
    @time_entry ||= TimeEntry.new(:project => @project, :issue => @issue, :user => User.current, :spent_on => User.current.today)
    @time_entry.safe_attributes = params[:time_entry]
    if @time_entry.project && !User.current.allowed_to?(:log_time, @time_entry.project)
      render_403
      return
    end

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_create)
          if params[:continue]
            options = {
              :time_entry => {
                :project_id => params[:time_entry][:project_id],
                :issue_id => @time_entry.issue_id,
                :activity_id => @time_entry.activity_id
              },
              :back_url => params[:back_url]
            }
            if params[:project_id] && @time_entry.project
              redirect_to new_project_time_entry_path(@time_entry.project, options)
            elsif params[:issue_id] && @time_entry.issue
              redirect_to new_issue_time_entry_path(@time_entry.issue, options)
            else
              redirect_to new_time_entry_path(options)
            end
          else
            redirect_back_or_default project_time_entries_path(@time_entry.project)
          end
        }
        format.api  { render :action => 'show', :status => :created, :location => time_entry_url(@time_entry) }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def edit
    @time_entry.safe_attributes = params[:time_entry]
  end

  def update
    @time_entry.safe_attributes = params[:time_entry]

    call_hook(:controller_timelog_edit_before_save, { :params => params, :time_entry => @time_entry })

    if @time_entry.save
      respond_to do |format|
        format.html {
          flash[:notice] = l(:notice_successful_update)
          redirect_back_or_default project_time_entries_path(@time_entry.project)
        }
        format.api  { render_api_ok }
      end
    else
      respond_to do |format|
        format.html { render :action => 'edit' }
        format.api  { render_validation_errors(@time_entry) }
      end
    end
  end

  def bulk_edit
    @available_activities = @projects.map(&:activities).reduce(:&)
    @custom_fields = TimeEntry.first.available_custom_fields.select {|field| field.format.bulk_edit_supported}
  end

  def bulk_update
    attributes = parse_params_for_bulk_update(params[:time_entry])

    unsaved_time_entries = []
    saved_time_entries = []

    @time_entries.each do |time_entry|
      time_entry.reload
      time_entry.safe_attributes = attributes
      call_hook(:controller_time_entries_bulk_edit_before_save, { :params => params, :time_entry => time_entry })
      if time_entry.save
        saved_time_entries << time_entry
      else
        unsaved_time_entries << time_entry
      end
    end

    if unsaved_time_entries.empty?
      flash[:notice] = l(:notice_successful_update) unless saved_time_entries.empty?
      redirect_back_or_default project_time_entries_path(@projects.first)
    else
      @saved_time_entries = @time_entries
      @unsaved_time_entries = unsaved_time_entries
      @time_entries = TimeEntry.where(:id => unsaved_time_entries.map(&:id)).
        preload(:project => :time_entry_activities).
        preload(:user).to_a

      bulk_edit
      render :action => 'bulk_edit'
    end
  end

  def destroy
    destroyed = TimeEntry.transaction do
      @time_entries.each do |t|
        unless t.destroy && t.destroyed?
          raise ActiveRecord::Rollback
        end
      end
    end

    respond_to do |format|
      format.html {
        if destroyed
          flash[:notice] = l(:notice_successful_delete)
        else
          flash[:error] = l(:notice_unable_delete_time_entry)
        end
        redirect_back_or_default project_time_entries_path(@projects.first), :referer => true
      }
      format.api  {
        if destroyed
          render_api_ok
        else
          render_validation_errors(@time_entries)
        end
      }
    end
  end

private
  def find_time_entry
    @time_entry = TimeEntry.find(params[:id])
    @project = @time_entry.project
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def check_editability
    unless @time_entry.editable_by?(User.current)
      render_403
      return false
    end
  end

  def find_time_entries
    @time_entries = TimeEntry.where(:id => params[:id] || params[:ids]).
      preload(:project => :time_entry_activities).
      preload(:user).to_a

    raise ActiveRecord::RecordNotFound if @time_entries.empty?
    raise Unauthorized unless @time_entries.all? {|t| t.editable_by?(User.current)}
    @projects = @time_entries.collect(&:project).compact.uniq
    @project = @projects.first if @projects.size == 1
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  def find_optional_issue
    if params[:issue_id].present?
      @issue = Issue.find(params[:issue_id])
      @project = @issue.project
    else
      find_optional_project
    end
  end

  def find_optional_project
    if params[:project_id].present?
      @project = Project.find(params[:project_id])
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

  # Returns the TimeEntry scope for index and report actions
  def time_entry_scope(options={})
    @query.results_scope(options)
  end

  def retrieve_time_entry_query
    retrieve_query(TimeEntryQuery, false)
  end
end
