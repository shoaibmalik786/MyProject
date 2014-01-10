class PhoneNumber < ActiveRecord::Base
  before_save   -> { self[:verified] = true if (self[:user_input] and
                                                self[:user_input] == self[:verification_code]) }
  before_create -> { self[:verification_code] = rand.to_s[2..7] }
end
