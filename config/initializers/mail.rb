ActionMailer::Base.smtp_settings = {
  user_name: Convection.config.smtp_user,
  password: Convection.config.smtp_password,
  address: Convection.config.smtp_address,
  port: Convection.config.smtp_port,
  domain: Convection.config.smtp_domain,
  authentication: :plain,
  enable_starttls_auto: true
}
