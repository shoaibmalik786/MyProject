# /lib/tasks/asset_deploy.rake
require 'rubygems'
require 'aws/s3'

## I like to namespeace my rake tasks. 
namespace :assets do 
  desc "Deploy all assets in public/**/* to S3/Cloudfront"
  task :deploy => [:environment] do
    STDOUT.sync = true
    installed = system("which s3cmd > /dev/null 2>&1")
    unless installed
      print "run `brew install s3cmd` and try again - you do not have the s3cmd binary installed."
    else
      print "== Uploading assets to S3"
      # you can specify as many directories as you like - make sure your local and remote match up properly. i use gsub because i am lazy
      ["public/images/*","public/stylesheets/*", "public/assets/*", "themes/*"].each do |local_path|
        remote_path = local_path.gsub("*", "").gsub("public/", "")
        print "Uploading #{local_path} to #{remote_path} \n"
        # my theme directory also has templates, but i dont want them on S3. read the docs for the other options explanations
        print `s3cmd -c .s3cfg --skip-existing  --rexclude=".*\.erb|.*\.haml" --acl-public -rvMH sync #{local_path} s3://#{AWS_ASSETS_BUCKET}/#{remote_path}`
      end
      
      print "== Done uploading assets to S3"
    end
    STDOUT.sync = false
  end
end
