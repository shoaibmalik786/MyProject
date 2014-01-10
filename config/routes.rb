Tradeya::Application.routes.draw do


  resources :trade_communications


  resources :passive_trades do
    member do
      get :my_haves_tab
      get :communication_tab
      get :trader_haves_tab
    end
    resources :transactions
  end

  mount Resque::Server, :at => "/resque"

  # root :to => "home#index"
  root :to => "home#invite"
  # match 'invite' => 'home#invite'
  match 'friends_invite' => 'users#friends_invite'
  match 'home' => 'home#index'
  match 'trade_page' => 'items#trade_page'

  match 'welcome' => 'home#welcome'
  match 'holiday' => 'home#holiday'
  match 'getstarted' => 'home#getstarted'

  resources :accepted_offers, :only => [:create]
  resources :comments,:only => [:create,:destroy]
  resources :authentications
  resources :reviews

  # post 'charges/create'
  #post "charge_cards/create"
  resources :charge_cards, :only => [:index,:create,:destroy]
# mailboxer
  resources :conversations, :only => [:show] do
    member do
      post 'reply'
      get 'download'
      get 'displaytrash'
      get 'displayinbox'
      get 'trash'
      get 'markasunread'
      get 'markasread'
      get 'delete'
      get 'untrash'
      get 'newmsg'
    end
  end
  # match 'conversations/trash' => 'conversations#trash', via: [:post]

  resources :verify_phone_number do
    member { post 'twilio_hack' }
    member { post 'show' }
  end

  resources :trades do
    member do
      post :reject
      #   post :rate
      get :my_haves_tab
      get :communication_tab
      get :trader_haves_tab
      get :confirm
      post :complete
      get :accept_terms
      post :update
    end
    resources :transactions 
  end
  match "transactions/get_shipping" => "transactions#get_shipping"
   match "transactions/update_address" => "transactions#update_address"
   match "transactions/trade_review" => "transactions#trade_review"
   match "transactions/make_trade" => "transactions#make_trade"
  # Namespace for mobile api
  namespace :api, defaults:{format: 'json'} do
    namespace :v1 do
      devise_scope :user do
        post 'registrations' => 'registrations#create', :as => 'register'
        post 'sessions' => 'sessions#create'
        delete 'sessions' => 'sessions#destroy'
      end

      # items api calls
      get 'items' => 'items#index', :as => 'items'
      post 'items' => 'items#create'
      get 'items/:id' => 'items#show'
      post 'items/:id/likes' => 'items#likes'
      post 'items/:id/wants' => 'items#wants'
      post 'items/:id/haves' => 'items#haves'
      post 'items/:id/comment' => 'items#comment'

      get 'categories' => 'home#categories'

      # user profile api
      get 'users/:id' => 'users#show'
      get 'users/:id/likes' => 'users#likes'
      get 'users/:id/wants' => 'users#wants'
      get 'users/:id/haves' => 'users#haves'
      get 'users/:id/following' => 'users#followed_users'
      get 'users/:id/followers' => 'users#followers'
      post 'users/:id/follow' => 'users#follow'
      get 'users/:id/past_trades' => 'users#past_trades'
      post 'users/search' => 'users#search'
    end
  end

  ActiveAdmin.routes(self)
  devise_for :users,
  :controllers => {
    :registrations => 'registrations',
    :passwords => 'passwords',
    :sessions => 'sessions',
    :confirmations => 'confirmation'}
    # :invitations => 'invitations'}

  devise_scope :user do
    match 'failure' => 'sessions#failure'
    match 'update_zip' => 'registrations#update_zip', :as => :update_zip
    match 'update_account_settings' => 'registrations#update_account_settings', :as => :update_account_settings
    match 'change_user_password' => 'registrations#change_user_password', :as => :change_user_password
    match 'deactivate_account' => 'registrations#deactivate_account', :as => :deactivate_account
    match 'create_guest' => 'registrations#create_guest', :as => :create_guest, :via => :post
    match 'update_guest' => 'registrations#update_guest', :as => :update_guest, :via => :post
    match 'guest_deactivate_account' => 'registrations#guest_deactivate_account', :as => :guest_deactivate_account
  end

  # resources :items, :only => [:create, :show, :new]
  resources :items do
    member do
      post 'like'
      post 'haves'
      post 'wants'
      get 'trade_offers'
      get 'my_offers'
      get 'accepted_offers'
      get 'rejected_offers'
      get 'wants_detail'
      post 'remove_have'
      post 'remove_offer'
      post 'want_cancel'
      post 'main_photo'
      post 'request_info'
      post 'edit_photo'
    end
  end

  resources :users, :only => [:show, :edit, :update] do
    member do
      post 'follow'
      get 'dashboard'
      get 'wants'
      get 'haves'
      get 'likes'
      get 'reviews'
      get 'following'
      get 'followers'
      get 'facebook_friends'
      get 'twitter_friends'
      get 'following_tab_search'
      get 'past_trades'
      get 'myoffers'
      get 'activity_feed'
      get 'inbox'
      post 'inbox'
      get 'sort_review'
      get 'settings'
      get 'invite'
      get 'pvt_msg_tab'
      get 'messaging'
      # get 'notifications'
      get 'inbox/messaging'
      get 'inbox/notifications'
      # post 'reinvite'
      post 'resend_invite'
      post 'resend_invite_to_all'
      post 'update_settings'
      post 'update_wants_message_reminder'
      post 'user_main_photo'
      post 'delete_activity'
      post 'delete_alert'
      post 'edit_photo'
      get 'active_trades'
      get 'my_wants'
      get 'wants_on_my_haves'

    end
    resources 'addresses'
    
    collection do
      get 'check_email'
    end
  end

  get 'users' => 'users#index'
  get 'users/pvt_msg_tab' => 'users#pvt_msg_tab'
  resources :browse, :controller => "items"
  match 'edit_profile' => 'users#edit_profile'
  match 'settings' => 'users#settings'





  # resources :home, :only => [:index]

  # controller :home do
  #   match :contest, :to => 'home#contest', :as => :contest, :via => :get
  #   match :contest_send_mail, :to=> 'home#contest_send_mail', :as => :contest_send_mail, :via => :post
  #   match :contest_share, :to=> 'home#contest_share', :as => :contest_share, :via => :post
  # end


  mount Split::Dashboard, :at => 'ab-tests'

  match 'reinvite' => 'users#reinvite', :via => :post
  # match 'reject_offer' => 'trades#reject_offer'
  match 'delete_user_photo' => 'common#delete_user_photo', :via => :post
  match 'delete_item_photo' => 'common#delete_item_photo', :via => :post
  match 'reply' => 'comments#reply', via: :post
  # match 'request_info' => 'common#request_info', :as => 'request_info'
  match 'thanks' => 'common#thanks'
  match 'change_location' => 'common#change_location'
  match 'auth/:provider/callback' => 'authentications#create'
  match '/auth/failure' => 'common#twitter_failure'
  match 'image_preview' => 'common#image_preview'
  match 'video_preview' => 'common#video_preview'
  match "password_reset" => "common#password_reset"
  match 'is_signed_in' => 'common#is_signed_in'
  match 'is_pub' => 'common#is_pub'
  match 'sign_in_success' => 'common#sign_in_success'
  match 'facebook_sign_in_success' => 'common#facebook_sign_in_success'
  match 'modals' => 'common#modals'
  match 'privacy_policy' => 'common#privacy_policy'
  match 'tandc' => 'common#tandc'
  match 'howthisworks' => 'common#howthisworks'
  match "password_changed" => "common#password_changed"
  match "after_sign_up" => "common#after_sign_up"
  match "after_sign_up_guest" => "common#after_sign_up_guest"
  match "after_change_password" => "common#after_change_password"
  match 'contact' => 'common#contact'
  match 'twitter_share_login' => 'common#twitter_share_login'
  match 'twitter_share' => 'common#twitter_share'
  match 'linkedin_login' => 'common#linkedin_login'
  match 'linkedin_share' => 'common#linkedin_share'
  match 'publink' => 'common#publink'
  match 'tradeya_expired' => 'items#tradeya_expired'
  match 'dead_link' => 'common#dead_link'
  match 'update_profile' => 'common#update_profile', :as => :update_profile
  match 'edit_user_image' => 'common#edit_user_image'
  match 'add_verification_success' => 'common#add_verification_success'
  match 'search_my_offer' => 'common#search_my_offer'
  match 'search_my_item_wants' => 'common#search_my_item_wants'
  match 'offer_data' => 'common#offer_data'
  match 'item_want_data' => 'common#item_want_data'
  match 'rotate_video' => 'common#rotate_video'
  match 'failure_network' => 'common#failure_network'
  # match 'at' => 'common#update_auth_token'

  match 'clear_all_cache' => 'common#clear_all_cache'
  match 'clear_item_cache' => 'items#clear_cache'
  match 'clear_category_cache' => 'common#clear_cache'
  match 'clear_home_cache' => 'home#clear_cache'
  match 'test_ad_tags' => 'home#test_ad_tags'
  match 'after_update_guest' => 'common#after_update_guest'

  match 'thumb_up_down/:v/:t' => 'thumb_up_downs#thumb_up_down'

  match "update_accept_offer_modal" => "accepted_offers#update_accept_offer_modal"
  match "accept_multiple_offers" => "accepted_offers#accept_multiple_offers", :via => :post

  match "items_distance" => "items#items_distance"
  match "search_by_zip" => "items#search_by_zip"
  match "complete_trade" => "items#complete_trade", :via => :post
  match 'postpone_trade' => 'items#postpone_trade', :via => :post
  match 'crop_image' => 'items#crop_image', :via => :post
  match 'update_user_categories' => 'profile#update_user_categories', :via => :post
  match 'thumbs_down_feedback' => 'thumb_up_downs#thumbs_down_add_reason', :via => :post

  match 'dashboard' => 'home#dashboard'
  match 'manage_tradeyas' => 'home#manage_tradeyas'
  match 'manage_offers' => 'home#manage_offers'
  match 'edit_settings' => 'home#edit_settings'
  match 'edit_verifications' => 'home#edit_verifications'
  match 'mark_alert_read_and_redirect' => 'home#mark_alert_read_and_redirect'
  match 'refresh_alert_count_and_show_new' => 'home#refresh_alert_count_and_show_new'
  match 'refresh_user_greet_notification_count' => 'home#refresh_user_greet_notification_count'
  match 'suggest_new_category' => 'profile#suggest_new_category'

  match 'send_verification_code_via_sms' => 'verify_phone_number#send_verification_code_via_sms'
  match 'verify_phone_number_via_sms' => 'verify_phone_number#verify_phone_number_via_sms'
  match 'remove_verification' => 'verify_phone_number#remove_verification', :as => :remove_verification, :via => :post
  match 'remove_number_verification' => 'verify_phone_number#remove_number_verification' , :as => :remove_number_verification, :via => :post
  match 'twilio_call_verification_status' => 'verify_phone_number#twilio_call_verification_status'

  match 'submit_user_review/:token' => 'reviews#new', :as => "submit_review"
  match 'review_flag' => 'reviews#flagReview'
  match 'profile' => 'profile#index'
  match 'execute_matching' => 'profile#execute_matching'
  match 'search_similar_categories' => 'profile#search_similar_categories'
  match 'unsubscribe_mail' => 'common#unsubscribe_mail'
  match 'search_potential_match' => 'profile#search_potential_match'
  match 'browser-campn-1-13' => 'items#index'
  match 'getUserData' => 'common#getUserData'
  match 'get_user_tradeyas' => 'items#get_user_tradeyas'
  match 'hello_modal_timer' => 'common#hello_modal_timer'

  match 'profile_page' => 'items#profile_page'
  match ':id/Goods(/:cat(/:title(/:loc(/:name))))' => 'items#show'
  match ':id/goods(/:cat(/:title(/:loc(/:name))))' => 'items#show'
  match ':id/Services(/:cat(/:title(/:loc(/:name))))' => 'items#show'
  match ':id/services(/:cat(/:title(/:loc(/:name))))' => 'items#show'
  # match ':id/:title(/:loc(/:name))' => 'items#show'
end
