require 'src/fs/node_mapper/version'

module SRC
  module FS
    class NodeMapper
      require 'json'

      class PathInvalidException < Exception
      end

      class MetaKeyInvalidException < Exception
      end

      def initialize(path, custom_opts = {}, &block)
        @path                 = path
        @nodes                = {}
        @node_meta            = {}
        @meta_rules           = {}
        @current_node         = nil
        @current_node_content = nil
        @opts                 = {
          cache:      false,
          cache_file: '.nodemapper'
        }.merge!(custom_opts)

        @opts[:cache_file] = "#{@path}/#{@opts[:cache_file]}"

        if path != File.absolute_path(path)
          raise PathInvalidException, 'path must be absolute'
        end

        load_from_cache if @opts[:cache]

        instance_eval(&block) if block_given?
      end

      def scan
        @nodes = scan_path(@path)
      end

      def metify
        metify_nodes(nodes)
      end

      def nodes
        @nodes
      end

      def node_meta(node = nil)
        if !node.nil?
          puts node
          puts @node_meta.inspect
          meta = @node_meta[node]
        else
          meta = @node_meta
        end

        meta = {} if meta.nil?

        meta
      end

      def add_meta_rule(rule, meta_key, custom_opts = {}, &block)
        meta_rule(rule, meta_key, custom_opts, &block)
      end

      def cache
        file = File.open(@opts[:cache_file], 'w')
        file.write({ nodes: nodes, node_meta: node_meta }.to_json)
        file.close
      end


      private

      def load_from_cache
        if File.exist?(@opts[:cache_file])
          file          = File.open(@opts[:cache_file], 'r')
          file_content  = JSON.parse(file.read)
          @nodes        = file_content['nodes']
          @node_meta    = file_content['node_meta']
          file.close
        end
      end

      def metify_nodes(nodes)
        nodes.each do |node_name, node|
          @meta_rules.each do |meta_rule, meta_options|
            if meta_rule.class.name == 'String'
              meta_rule = Regexp.escape(meta_rule).gsub('\*','.*?')
            end

            if node['path'].match(meta_rule) || node_name.match(meta_rule)
              eval_meta_for_node(node, meta_options)
            end

            if node['type'] == 'dir' && node['nodes'].length
              metify_nodes(node['nodes'])
            end
          end
        end
      end

      def eval_meta_for_node(node, meta)
        current_node(node)

        meta.each do |meta_key, meta_options|
          meta_value = self.instance_exec(node, &meta_options[:block])

          if meta_options[:include_nil] || (!meta_options[:include_nil] && !meta_value.nil?)
            @node_meta[node['path']] = {} if !@node_meta[node['path']]
            @node_meta[node['path']][meta_key.to_s] = meta_value
          end
        end

        reset_current_node
      end

      def reset_current_node
        @current_node         = nil
        @current_node_content = nil
      end

      def node_content
        if File.file?(@current_node['path'])
          @current_node_content ||= File.read(@current_node['path'])
        end
      end

      def current_node(node_data)
        @current_node = node_data
      end

      def meta_rule(rule, meta_key, custom_opts = {}, &block)
        meta_key = meta_key.to_sym
        opts     = {
          include_nil: false
        }.merge!(custom_opts)

        @meta_rules[rule] = {} if !@meta_rules[rule]
        @meta_rules[rule][meta_key.to_sym] = opts.merge!({
          block: block
        })
      end

      def scan_path(path)
        nodes = {}

        Dir.glob("#{path}/*") do |node_path|
          node_name        = File.basename node_path
          nodes[node_name] = { 'path' => node_path, 'type' => 'file' }

          if File.directory?(node_path)
            nodes[node_name]['type']  = 'dir'
            nodes[node_name]['nodes'] = scan_path(node_path)
          end
        end

        nodes
      end
    end
  end
end