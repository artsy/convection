require 'ddtrace'

Datadog.configure do |c|
  enabled = Convection.config[:datadog_trace_agent_hostname].present?
  hostname = Convection.config[:datadog_trace_agent_hostname]
  debug = Convection.config[:datadog_debug] == 'true'

  c.tracer enabled: enabled, hostname: hostname, distributed_tracing: true, debug: debug
  c.use :rails, service_name: 'convection', controller_service: 'convection.controller', cache_service: 'convection.cache'
  c.use :redis, service_name: 'convection.redis'
  c.use :http, service_name: 'convection.http', distributed_tracing: true
end
