require 'ddtrace'

Datadog.configure do |c|
  enabled = ENV['DATADOG_TRACE_AGENT_HOSTNAME'].present?
  hostname = ENV['DATADOG_TRACE_AGENT_HOSTNAME']
  debug = ENV['DATADOG_DEBUG'] == 'true'

  c.tracer enabled: enabled, hostname: hostname, distributed_tracing: true, debug: debug
  c.use :rails, service_name: 'convection', controller_service: 'convection.controller', cache_service: 'convection.cache'
  c.use :redis, service_name: 'convection.redis'
  c.use :http, service_name: 'convection.http', distributed_tracing: true
end
