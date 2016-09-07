require "honeybadger-api"
require "pry"
require "csv"

Honeybadger::Api.configure do |c|
  c.access_token = ENV.fetch("HONEYBADGER_PRODUCTION_AUTH_TOKEN", "Please specify a honeybadger authentication token.")
end

DATA_DIR = File.expand_path("../../data", __FILE__)
CSV_COLUMN_HEADERS = ["action", "comments_count", "component", "created_at", "deploy_revision", "environment", "error_class", "error_message", "id", "ignored", "last_notice_at", "notices_count", "project_id", "resolved", "tags", "url"]

project = Honeybadger::Api::Project.all.first
paginator = Honeybadger::Api::Fault.paginate(project.id)
pages = paginator.pages.values

csv_path = File.join(DATA_DIR, "#{project.name}-faults.csv")
json_path = File.join(DATA_DIR, "#{project.name}-faults.json")
arr = []

CSV.open(csv_path, "w") do |csv|
  csv << CSV_COLUMN_HEADERS

  pages.each do |page|
    while page.any?
      page.each do |fault|
        item = {
          :action => fault.action,
          :comments_count => fault.comments_count,
          :component => fault.component,
          :created_at => fault.created_at.to_s,
          :deploy_revision => (fault.deploy.revision if fault.deploy),
          :environment => fault.environment,
          :error_class => fault.klass,
          :error_message => fault.message,
          :id => fault.id,
          :ignored => fault.ignored?,
          :last_notice_at => fault.last_notice_at.to_s,
          :notices_count => fault.notices_count,
          :project_id => fault.project_id,
          :resolved => fault.resolved?,
          :tags => fault.tags,
          :url => fault.url
        }

        puts "#{item[:id]} -- #{item[:created_at]} -- #{item[:error_class]}"
        csv << item.values
        arr << item
      end

      page = paginator.next? ? paginator.next : []
    end
  end
end

File.write(json_path, JSON.pretty_generate(arr))
