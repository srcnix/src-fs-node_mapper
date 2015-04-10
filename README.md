# SRC::FS::NodeMapper

SRC::FS::NodeMapper is a simple library for mapping a path structure and applying meta to each node dynamically.

NodeMapper maps each node within the specified path and then allows you to easily apply meta data with simplicity, through regular expressions.

Features:

* Fast
* Simple to use
* Easily accessible hash of nodes
* Node meta mapping
* Caching (7-8 times faster)

Why would I want to use this?

* You need to be aware of all files in a directory, and require specific information (meta) about different files easily
* You don't see the point in storing file system structures and relative meta in a database
* Some more reasons I'm sure, I'm working on it!

## Installation

Clone from Github, this gem is not yet stable.

## Usage

This library allows you to do two things. Map directory structures and map meta data against the structure.

Mapping a directory will take the something like the following structure within /var/www/sites:

```
/dir_1
/dir_1/file_1
/dir_2
/dir_2/file_1
```

And map it into an easily accessible hash:

```ruby
# {
#   'dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1',
#     'nodes' => {
#       'file_1' => { 'type' => 'file', 'path' => '/var/www/sites/dir_1/file_1' }
#     }
#   },
#   'dir_2' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_2',
#     'nodes' => {
#       'file_2' => { 'type' => 'file', 'path' => '/var/www/sites/dir_2/file_2' }
#     }
#   }
# }
```

Metifying the data will allow you to dynamically and easily apply meta data against the above structure.

### Map nodes in directory

```ruby
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites')
dir_mapper.scan # Scans directory structure and maps to hash

dir_mapper.nodes # => { dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1', 'nodes' => {...
```

By default, scan will scan deeply. You can disable deep scans to the first level by padding deep:false.

```ruby
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites')
dir_mapper.scan deep: false # Scans first level

dir_mapper.nodes # => { dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1' }...
```

### Store mapped nodes in cache

You can also cache the mapped nodes by calling #cache.

Storing the mapped structure in a cache can easly increase speed by 7-8 times.

By default, cache files are named .nodemapper and are stored at the root of the path you are mapping.

```ruby
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites')
dir_mapper.scan # Scans directory structure and maps to hash
dir_mapper.cache
```

If you would like to change the name of the cache file, pass cache_file as an optional param

```ruby
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites', cache_file: '.my_cache')
dir_mapper.scan # Scans directory structure and maps to hash
dir_mapper.cache
```

### Read mapped nodes from cache

To read from the cache, pass in cache: true as an optional param.

```ruby
dir_mapper_cached = SRC::FS::NodeMapper.new('/var/www/sites', cache: true)
dir_mapper_cached.nodes # => { dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1', 'nodes' => {...
```

If you have a custom cache file name, ensure you pass it in when reading from the cache.

```ruby
dir_mapper_cached = SRC::FS::NodeMapper.new('/var/www/sites', cache: true, cache_file: '.my_cache')
dir_mapper_cached.nodes # => { dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1', 'nodes' => {...
```

### Re-scan (remap) after cache exists

```ruby
dir_mapper_cached = SRC::FS::NodeMapper.new('/var/www/sites', { cache: true })
dir_mapper_cached.scan # Re-scan directory structure
dir_mapper_cached.cache # Updates cache
```

### Metify mapped nodes

In order to metify mapped nodes, you will need to specify meta rules. Adding meta rules is easy, and powerful.

You can add meta rules using #add_meta_rule and calling #metify.

Notes:
* Rules are checked against both the node's name and the node's path

\#add_meta_rule requires 2 options, optional custom_options and a block

* rule (String|Regexp)
* meta_key (String|Symbol)
* custom_options
  * :include_nil (Boolean)
    Whether or not to map meta if the meta value is nil
* block

The block is used to determine the value for the meta. Inside the block you have access to the following

* node (The node's type and path)
* node_content (The contents of the current node being metified)

```ruby
# Adds :length meta to file, giving the length of the content to specific files based on the rule
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites')

dir_mapper.add_meta_rule('file_*', :length) do |node|
  node_content.length
end

dir_mapper.scan # Maps nodes
dir_mapper.metify # Applies meta rules
dir_mapper.nodes # => # => { dir_1' => { 'type' => 'dir', 'path' => '/var/www/sites/dir_1', 'nodes' => {...
dir_mapper.node_meta # => { '/var/www/sites/file_1' => { 'length' => 16 }...
```

You can also add meta rules during initialization by passing in a block.

```ruby
dir_mapper = SRC::FS::NodeMapper.new('/var/www/sites') do
  add_meta_rule('file_*', :length) do |node|
    node_content.length
  end
end

dir_mapper.scan
dir_mapper.metify
```

## Contributing

1. Fork it ( https://github.com/srcnix/src-fs-node_mapper/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request