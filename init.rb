require 'redmine'
require_dependency 'notifier_hook'

Redmine::Plugin.register :redmine_campfire_notifications do
  name 'Redmine IRC Notifications plugin'
  author 'xdite'
  description 'A plugin to display issue modifications to a Irc Channel'
  version '0.0.1'
end
