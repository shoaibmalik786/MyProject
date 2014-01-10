# /cookbooks/s3cmd/recipes/default.rb
# Cookbook Name:: s3cmd
# Recipe:: default

s3cmd_tar_gz = "/engineyard/portage/distfiles/s3cmd-1.0.0.tar.gz"

remote_file s3cmd_tar_gz do
  checksum "e82f0246479015ce50a09d8d4ada8429"
  source "http://downloads.sourceforge.net/project/s3tools/s3cmd/1.0.0/s3cmd-1.0.0.tar.gz"
end

bash "install s3cmd 1.0.0" do
  cwd "/engineyard/portage/distfiles/"
  code <<-EOH
    tar -zxf #{s3cmd_tar_gz}
    cd /engineyard/portage/distfiles/s3cmd-1.0.0 && sudo ln -nfs $PWD/s3cmd /usr/local/bin/s3cmd
  EOH
  not_if { ::FileTest.exists?("/usr/local/bin/s3cmd") }
end
