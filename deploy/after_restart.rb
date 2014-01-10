# run "echo '************** After Restart ************' >> #{shared_path}/logs.log"
#run "echo 'release_path: #{release_path}' >> #{shared_path}/logs.log"
#run "echo 'current_path: #{current_path}' >> #{shared_path}/logs.log"
#run "echo 'latest_release: #{latest_release()}' >> #{shared_path}/logs.log"
#run "echo 'previous_release: #{previous_release()}' >> #{shared_path}/logs.log"

# run "cd #{release_path} && bundle exec rake sunspot:solr:start"
# run "cd #{release_path} && bundle exec rake sunspot:reindex"

run "sudo monit start all -g tradeya_resque"