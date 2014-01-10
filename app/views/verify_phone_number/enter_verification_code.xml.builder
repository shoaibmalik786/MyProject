xml.instruct!
xml.Response do
  xml.Gather(:action => @post_to, :numDigits => 6) do
    xml.Say "Hello. Please enter your 6 digit tradeya verification code.", :voice => 'woman'
  end
  xml.Say "I'm sorry, you have not entered the code", :voice => 'woman'
end