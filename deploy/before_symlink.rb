#run "echo 'release_path: #{release_path}/public' >> #{shared_path}/logs.log"
# run "ln -s #{shared_path}/tmp_files #{release_path}/public/tmp_files"
# run "rm #{shared_path}/tmp_files/*"
# run "cd #{release_path} && bundle exec rake sunspot:solr:stop"
# run "cd #{release_path} && bundle exec rake sunspot:solr:start"
# run "cd #{release_path} && bundle exec rake sunspot:reindex"
run "sudo monit stop all -g tradeya_resque"
if %x[ps axo command|grep resque[-]|grep -c Forked].to_i > 0
  raise "Resque Workers Working!!"
end
