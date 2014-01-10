class DeviseMailer  < Devise::Mailer
  helper :application
  include Devise::Controllers::UrlHelpers # Optional. eg. `confirmation_url`
  include SendGrid
  sendgrid_enable   :ganalytics

  def activation_instructions(record, token, opts={})
    headers['X-SMTPAPI'] = '{"category": "Activation Email"}'
    sendgrid_ganalytics_options(record.utm_params) if record.tracking_info.present?
    super
  end

  def confirmation_instructions(record, token, opts={})
    headers['X-SMTPAPI'] = '{"category": "Confirmation Email"}'
    sendgrid_ganalytics_options(record.utm_params) if record.tracking_info.present?
    super
  end

  def password_reset_instructions(record, token, opts={})
    headers['X-SMTPAPI'] = '{"category": "Password Reset"}'
    sendgrid_ganalytics_options(record.utm_params) if record.tracking_info.present?
    super
  end
  
  def invitation_instructions(record, token, opts={})
    headers['X-SMTPAPI'] = '{"category": "Request Invite"}'
    super
  end

end
