def app_name
  @app_name ||= File.basename(root)
end

def app_name_underscore
  @app_name_underscore ||= app_name.gsub(' ', '_').underscore
end

#====================
# PREPARE
#====================
FileUtils.rm_rf %w(public/index.html public/images/rails.png test)
run 'touch public/stylesheets/application.css db/schema.rb'

file 'README', <<-END
#{app_name}
===============================
END

file 'config/routes.rb', <<-END
ActionController::Routing::Routes.draw do |map|
end
END

file 'config/database.yml', <<-END
development: 
  adapter: mysql
  username: root
  password: 
  database: #{app_name_underscore}_development
test: 
  adapter: mysql
  username: root
  password: 
  database: #{app_name_underscore}_test
END

append_file 'Rakefile', <<-END
Rake::Task[:default].clear
task :default => :spec
END


#====================
# GEMS
#====================
gem 'giraffesoft-resource_controller', :lib => 'resource_controller', :source => "http://gems.github.com"
gem "haml"
gem 'mislav-will_paginate', :lib => 'will_paginate', :source => 'http://gems.github.com'
gem 'rspec', :lib => false, :git => 'git://github.com/dchelimsky/rspec.git'
gem 'rspec-rails', :lib => false, :git => 'git://github.com/dchelimsky/rspec-rails.git'
gem 'sandro-homeward', :lib => 'homeward', :source => 'http://gems.github.com'
gem 'thoughtbot-factory_girl', :lib => 'factory_girl', :source => 'http://gems.github.com'

#====================
# SETUP
#====================

rake "gems:install", :sudo => true
rake "db:create:all"

generate "rspec"

generate "homeward"
rake "homeward:install"

rake "log:clear"

#====================
# GIT
#====================

git :init

file '.gitignore', <<-END
.DS_Store
config/database.yml
config/settings.yml
coverage/*
db/*.db
db/*.sqlite3
doc/api
doc/app
log/*.log
tmp/**/*
tmp/tags
END

run "cp config/database.yml config/database.example.yml"
run 'find . \( -type d -empty \) -and \( -not -regex ./\.git.* \) -exec touch {}/.gitignore \;'

git :add => "."
git :commit => "-a -m 'Generated project'"
