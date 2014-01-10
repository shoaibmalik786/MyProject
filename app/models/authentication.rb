class Authentication < ActiveRecord::Base
  belongs_to :user
  after_create :follow_new_user

  def follow_new_user
    Resque.enqueue(FollowNewUserWorker,self.user_id)
  end
end
