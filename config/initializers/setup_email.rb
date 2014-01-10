ActionMailer::Base.smtp_settings = {
   :address              => "smtp.sendgrid.net",
   :domain               => DOMAIN,
   :user_name            => "tradeya",
   :password             => "tradeyarules1!!!",
   :authentication       => "plain",
   :enable_starttls_auto => true
}
