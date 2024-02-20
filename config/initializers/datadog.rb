# frozen_string_literal: true

require "ddtrace"

Datadog.configure do |c|
  c.tracer(
    enabled: Convection.config[:datadog_trace_agent_hostname].present?,
    hostname: Convection.config[:datadog_trace_agent_hostname],
    distributed_tracing: true,
    debug: Convection.config[:datadog_debug]
  )
  c.use :rails,
    service_name: "convection",
    controller_service: "convection.controller",
    cache_service: "convection.cache"
  c.use :redis, service_name: "convection.redis"
  c.use :http, service_name: "convection.http", distributed_tracing: true
  c.use :sidekiq, service_name: "convection.sidekiq"
end
