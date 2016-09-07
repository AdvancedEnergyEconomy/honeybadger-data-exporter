require "honeybadger-api"
require "pry"

Honeybadger::Api.configure do |c|
  c.access_token = ENV.fetch("HONEYBADGER_PRODUCTION_AUTH_TOKEN", "Please specify a honeybadger authentication token.")
end

project = Honeybadger::Api::Project.all.first
paginator = Honeybadger::Api::Fault.paginate(project.id)
pages = paginator.pages.values
pages.each do |page|
  while page.any?
    page.each do |fault|
      item = {
        :action => fault.action,
        :component => fault.component,
        :created_at => fault.created_at,
        :id => fault.id,
        :error_class => fault.klass,
        :error_message => fault.message,
        :notices_count => fault.notices_count
      }
      puts "#{item[:id]} -- #{item[:created_at].strftime('%Y-%m-%d')} -- #{item[:error_class]}"
      # TODO: WRITE ME TO CSV
    end
    page = paginator.next? ? paginator.next : []
  end
end
