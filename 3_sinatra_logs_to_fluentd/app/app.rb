require 'sinatra'

# This is set to get the error logging to show correctly
set :environment, :production

# the application logger. This won't print to stdout, but it will send the logs
# to fluentd
logger =  Fluent::Logger::LevelFluentLogger.new("my-ruby-sinatra-application", :host => 'fluentd', :port => 24224)

# This is so error handling works properly. 
class ErrorLogger
  def initialize(logger)
    @logger = logger
  end
  def puts(message)
    @logger.error(message)
  end
end

error_logger = ErrorLogger.new(logger)

before do
  env["rack.errors"] = error_logger
end

get "/" do
  logger.info("This is an info message")
  "Hello world! <a href=\"/hello\">Hello again?</a>"
end

get "/hello" do
  "Hello again"
end

#demonstrating an error message
get "/error" do
  raise StandardError, "some message"
end
