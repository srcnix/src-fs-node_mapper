require 'spec_helper'

describe SRC::FS::NodeMapper do
  it 'has a version number' do
    expect(SRC::FS::NodeMapper::VERSION).not_to be nil
  end

  context 'intialize' do
    it 'should require the path' do
      expect { SRC::FS::NodeMapper::NodeMapper.new() }.to raise_error
    end

    it 'should only accept an absolute path' do
      expect { SRC::FS::NodeMapper::NodeMapper.new('.') }.to raise_error
    end
  end

  context 'nodes' do
    before(:all) do
      @mapper = SRC::FS::NodeMapper.new(File.expand_path('../', File.dirname(__FILE__)))

      @mapper.scan
    end

    context '#nodes' do
      it 'should be a Hash' do
        expect(@mapper.nodes).to be_a(Hash)
      end
    end

    context '#nodes.first' do
      it 'should have a :path' do
        expect(@mapper.nodes.first[1].has_key?('path')).to be(true)
      end

      it 'should have a :type' do
        expect(@mapper.nodes.first[1].has_key?('type')).to be(true)
      end
    end
  end

  context 'node meta' do
    before(:all) do
      path = File.expand_path('../', File.dirname(__FILE__))
      @mapper = SRC::FS::NodeMapper.new(path) do
        meta_rule "#{path}/*", :ext, include_nil: false do |node|
          if node['type'].to_sym == :file
            File.extname(node['path'])
          end
        end
      end

      @mapper.scan
      @mapper.metify
    end

    context '#node_meta' do
      it 'should be a Hash' do
        expect(@mapper.node_meta).to be_a(Hash)
      end

    end

    context '#node_meta.first' do
      it 'should have a "ext" meta key/valye pair' do
        expect(@mapper.node_meta.first[1].has_key?('ext')).to be(true)
      end
    end
  end
end

