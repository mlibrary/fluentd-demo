require "byebug"
require "fluent-logger"
require_relative "app"

# If using fluentd for logs is something we actually start to do this will be
# gemefied and could be easily incorporated in an app. 
#
# Heavily influenced by: https://github.com/rack/rack/blob/main/lib/rack/common_logger.rb
# Somewhat influenced by: https://github.com/mikhailvs/rack-fluentd-logger/blob/master/lib/rack/fluentd_logger.rb
# Format of logs influenced by: https://docs.fluentd.org/parser/apache2 
#
# What this is doing is outputing json logs to fluentd that contain the same info
# that would be in Apache Combined Logs format.
class MyLoggerMiddleware
  class << self
    attr_reader :logger

    def configure(
      name: ENV['FLUENTD_NAME'], 
      host: ENV['FLUENTD_HOST'], 
      port: (ENV['FLUENTD_PORT'] || '24224').to_i
    )
      @logger = Fluent::Logger::FluentLogger.new(name, :host => host, :port => port)
    end
  end

  def initialize(app)
    @app = app
    self.class.configure if self.class.logger.nil?
  end

  def call(env)
    began_at = Rack::Utils.clock_time
    status, headers, body = response = @app.call(env)

    response[2] = Rack::BodyProxy.new(body) { log(env, status, headers, began_at) }
    response
  end

  def log(env, status, response_headers, began_at)
    request = Rack::Request.new(env)
    length = extract_content_length(response_headers)

    time = Time.now
    time_stamp = "#{time.to_i} (#{time.strftime("%d/%b/%Y:%H:%M:%S %z")})"
    output = {}
    output[:time] = time_stamp
    output[:record] = {
      user: request.get_header("REMOTE_USER"),
      method: request.request_method,
      code: status.to_s[0..3],
      size: length,
      host: request.ip,
      path: request.path_info,
      query: request.query_string,
      referer: request.referer,
      agent: request.user_agent,
    }
    output[:response_time] =  Rack::Utils.clock_time - began_at
    self.class.logger.post("rack-traffic-log", output)
  end

  def extract_content_length(headers)
    value = headers["content-length"]
    !value || value.to_s == '0' ? '-' : value
  end
end

MyLoggerMiddleware.configure(
  name: 'my-ruby-sinatra-application',
  host: 'fluentd',
  port: 24224
)

use MyLoggerMiddleware

run Sinatra::Application
