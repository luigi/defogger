require 'compass'
# If you have any compass plugins, require them here.
require 'ninesixty'
Compass.configuration do |config|
  config.project_path = RAILS_ROOT
  config.sass_dir = "app/stylesheets"
  config.css_dir = "public/stylesheets"
end
Compass.configure_sass_plugin!
