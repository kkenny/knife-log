require 'chef/knife'
require 'highline'

module Limelight
  class NodeLog < Chef::Knife

    deps do
      require 'chef/search/query'
      require 'chef/knife/search'
    end

    banner "knife node log NODE"

    def h
      @highline ||= HighLine.new
    end

    def run
      unless @node_name = name_args[0]
        ui.error "You need to specify a node"
        exit 1
      end

      searcher = Chef::Search::Query.new
      result = searcher.search(:node, "name:#{@node_name}")

      knife_search = Chef::Knife::Search.new
      node = result.first.first
      if node.nil?
        puts "Could not find a node named #{@node_name}"
        exit 1
      end

      $stdout.sync = true

      if node[:log]
        log_entries = [ h.color('Time', :bold, :underline),
                        h.color('Recipe', :bold, :underline),
                        h.color('Action', :bold, :underline),
                        h.color('Resource Type', :bold, :underline),
                        h.color('Resource', :bold, :underline) ]
        node[:log].each do |log_entry|
          log_entries << log_entry[:time].to_s
          log_entries << "#{log_entry[:cookbook_name]}::#{log_entry[:recipe_name]}"
          log_entries << log_entry[:action].to_s
          log_entries << log_entry[:resource_type].to_s
          log_entries << log_entry[:resource].to_s
        end
        puts h.list(log_entries, :columns_across, 5)
        puts
      end
    end
  end
end
