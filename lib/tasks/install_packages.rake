# /lib/tasks/asset_deploy.rake
require 'rubygems'
require 'aws/s3'

## I like to namespeace my rake tasks. 
namespace :cmd do 
  desc "install s3cmd and mplayer"
  task :install_packages => [:environment] do
    # pkg_dir = "/Users/mukesh/packages"
    pkg_dir = "/home/deploy/packages"
    # pkg_dir = "/home/vagrant/packages"

    if !Dir.exists?(pkg_dir)
      Dir.mkdir(pkg_dir)
    end
    Dir.chdir(pkg_dir)

    installed = system("which s3cmd > /dev/null 2>&1")
    unless installed
      if !File.exists?(pkg_dir + "/s3cmd-1.0.0.tar.gz")
        system("wget http://downloads.sourceforge.net/project/s3tools/s3cmd/1.0.0/s3cmd-1.0.0.tar.gz")
      end
      if !Dir.exists?(pkg_dir + "/s3cmd-1.0.0")
        system("tar -zxf " + pkg_dir + "/s3cmd-1.0.0.tar.gz")
      end
      system("sudo ln -nfs " + pkg_dir + "/s3cmd-1.0.0/s3cmd /usr/local/bin/s3cmd")
    end
    
    installed = system("which yasm > /dev/null 2>&1")
    unless installed
      Dir.chdir(pkg_dir)

      if !File.exists?(pkg_dir + "/yasm-0.7.0.tar.gz")
        system("wget http://www.tortall.net/projects/yasm/releases/yasm-0.7.0.tar.gz")
      end
      if !Dir.exists?(pkg_dir + "/yasm-0.7.0")
        system("tar zfvx " + pkg_dir + "/yasm-0.7.0.tar.gz")
      end

      Dir.chdir(pkg_dir + "/yasm-0.7.0")
      system("./configure")
      system("sudo make")
      system("sudo make install")
      
      system("sudo ln -nfs " + pkg_dir + "/s3cmd-1.0.0/s3cmd /usr/local/bin/s3cmd")
    end

    installed = system("which mencoder > /dev/null 2>&1")
    unless installed
      Dir.chdir(pkg_dir)
      Dir.chdir(pkg_dir + "/subversion-1.6.0")
      system("make clean")
      system("./configure")
      system("sudo make")
      system("sudo make install")      
    end

    installed = system("which mencoder > /dev/null 2>&1")
    unless installed
      Dir.chdir(pkg_dir)

      if !Dir.exists?(pkg_dir + "/mplayer")
        system("svn checkout svn://svn.mplayerhq.hu/mplayer/trunk mplayer")
      end

      Dir.chdir(pkg_dir + "/mplayer")
      system("make clean")
      system("svn update")
      system("./configure")
      system("sudo make")
      system("sudo make install")
    end

    if !File.exists?("/usr/bin/mencoder")
      system("sudo cp /usr/local/bin/mencoder /usr/bin/mencoder")
    end
    system("sudo cp /home/deploy/tradeya.conf /etc/nginx/servers/")
  end
end
