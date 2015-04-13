require 'rubygems'
require 'bundler/setup'

require 'benchmark'

require_relative '../lib/src/fs/node_mapper'

path      = File.expand_path('../', File.dirname(__FILE__))
nodes     = {}
node_meta = {}

def display_nodes(nodes, node_meta, lvl = 0)
  lvl += 1 if lvl != 0

  nodes.each do |node, node_data|
    nodes     = node_data['nodes']
    node_data = node_data.dup
    prepend   = ' ' * lvl if lvl > 0

    node_data.delete('nodes')

    puts "#{prepend}(#{node_data['type']}) #{node}: #{node_data}"

    if node_meta.has_key?(node_data['path'])
      node_meta[node_data['path']].each do |key, val|
        puts "#{prepend} - #{key}: #{val}"
      end
    end

    if node_data['type'] == 'dir'
      lvl += 1 if lvl == 0

      display_nodes(nodes, node_meta, lvl)
    else
      lvl = 0
    end
  end
end

Benchmark.bm do |x|
  x.report('Direct') do
    dir_mapper = SRC::FS::NodeMapper.new(path) do
      meta_rule /\/var\/www\/gems\/src\/src\-fs\-node_mapper\/bin\/(.*)/, 'content_length' do |node|
        node_content.length
      end

      meta_rule '/var/www/gems/src/src-fs-node_mapper/*', :ext, include_nil: false do |node|
        if node['type'].to_sym == :file
          File.extname(node['path'])
        end
      end
    end

    dir_mapper.scan
    dir_mapper.metify
    dir_mapper.cache

    nodes     = dir_mapper.nodes
    node_meta = dir_mapper.node_meta

    #display_nodes(nodes, node_meta)
  end

  x.report('Cached') do
    dir_mapper  = SRC::FS::NodeMapper.new(path, cache: true)
    nodes       = dir_mapper.nodes
    node_meta   = dir_mapper.node_meta()

    #display_nodes(nodes, node_meta)
  end
end