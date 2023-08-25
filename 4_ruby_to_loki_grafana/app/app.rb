require 'fluent-logger'

# configure the fluent logger. The host is the fluentd service. The port is the
# default port fluentd listens on. It's also set in the fluent.conf
log = Fluent::Logger::FluentLogger.new(nil, :host => 'fluentd', :port => 24224)

#so the puts line shows as its run
$stdout.sync = true

while true do
 puts "logging some info"
 
 # "ruby-app" is the tag.
 log.post("ruby-app", {"info" => "a more different log message" })

 sleep 5
end
