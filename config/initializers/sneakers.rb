Sneakers.configure(
  connection: Bunny.new(
    Convection.config.rabbitmq_consume_url,
    tls: Convection.config.rabbitmq_client_cert.present?,
    verify_peer: Convection.config.rabbitmq_verify_peer,
    tls_cert: Convection.config.rabbitmq_client_cert,
    tls_key: Convection.config.rabbitmq_client_key,
    tls_ca_certificates: ([Convection.config.rabbitmq_ca_cert] if Convection.config.rabbitmq_ca_cert.present?),
    logger: Rails.logger,
    automatically_recover: Convection.config.sneakers_auto_recover
  ), # Overrides connection preferences with our own bunny (necessary for tls)
  log: Rails.logger,
  daemonize: false,
  pid_path: "tmp/pids/sneakers.pid",
  workers: 1
)
Sneakers.logger.level = Logger::INFO
