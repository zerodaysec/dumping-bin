#!/usr/bin/env ruby
require 'nexpose'
include Nexpose

nsc = Connection.new('nexpose.pci-company.local', 'username_here', 'xxxx', 443)
nsc.login
at_exit { nsc.logout }

nsc.sites.each do |site|
    config = Site.load(nsc, site.id)
    puts "#{site.name}-#{site.id}"
end
