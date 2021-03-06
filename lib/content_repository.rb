require 'digest'
require 'yaml'

class ContentRepository

  DEFAULT_TIME  = '2020-01-01T10:05:30Z'
  IGNORED_FILES = %w(.DS_Store .keep Thumbs.db)

  ##
  # @param uuid [String]
  # @return [String] URL path of the entity with the given UUID.
  #
  def path_for_uuid(uuid)
    Dir.glob(File.join(root, '/repositories/**/*')) do |path|
      relative_path = path.delete_prefix(root)
      other_uuid    = uuidify(relative_path)
      if other_uuid == uuid
        parts = relative_path.split('/')
        if parts.length == 3
          return "/repositories/#{parts[parts.length - 1]}"
        elsif parts.length == 5
          return "/collections/#{parts[parts.length - 1]}"
        elsif parts.length == 7
          return "/file_groups/#{parts[parts.length - 1]}"
        elsif File.directory?(path)
          return "/cfs_directories/#{idify(relative_path)}"
        else
          return "/cfs_files/#{idify(relative_path)}"
        end
      end
    end
    nil
  end

  def collections
    collections = []
    Dir.glob(File.join(root, '/repositories/*/collections/*')) do |collection_path|
      parts                    = collection_path.split('/')
      relative_collection_path = collection_path.delete_prefix(root)
      collection               = {}
      collection[:id]          = parts[parts.length - 1].to_i
      collection[:uuid]        = uuidify(relative_collection_path)
      collection[:path]        = "/collections/#{collection[:id]}"
      collections << collection
    end
    collections
  end

  def collection(id)
    id = id.to_i
    Dir.glob(File.join(root, '/repositories/*/collections/*')) do |collection_path|
      parts                    = collection_path.split('/')
      relative_collection_path = collection_path.delete_prefix(root)
      relative_repo_path       = parts[0..parts.length - 3].join('/').delete_prefix(root)
      collection_id            = parts[parts.length - 1].to_i
      next unless collection_id == id
      collection                    = ::YAML.load(File.read(File.join(collection_path, 'info.yml')))
      collection[:id]               = collection_id
      collection[:uuid]             = uuidify(relative_collection_path)
      repo_id                       = parts[parts.length - 3]
      collection[:repository_path]  = "/repositories/#{repo_id}"
      repo                          = ::YAML.load(File.read(File.join(collection_path, '..', '..', 'info.yml')))
      collection[:repository_title] = repo['title']
      collection[:repository_uuid]  = uuidify(relative_repo_path)
      collection[:file_groups]      = []
      Dir.glob(File.join(collection_path, 'file_groups', '*')) do |file_group_path|
        parts                     = file_group_path.split('/')
        file_group                = ::YAML.load(File.read(File.join(file_group_path, 'info.yml')))
        file_group.select!{ |k,v| %w(title storage_level).include?(k) }
        file_group[:id]           = parts[parts.length - 1].to_i
        file_group[:path]         = "/file_groups/#{file_group[:id]}.json"
        collection[:file_groups] << file_group
      end
      return collection
    end
    nil
  end

  def directory(id)
    id = id.to_i
    Dir.glob(File.join(root, '/repositories/*/collections/*/file_groups/*/**/*')) do |path|
      relative_dir_path = path.delete_prefix(root)
      dir_id            = idify(relative_dir_path)
      next unless dir_id == id
      dir = {
          id:                dir_id,
          uuid:              uuidify(relative_dir_path),
          name:              File.basename(relative_dir_path),
          relative_pathname: path.delete_prefix(root)[1..-1],
          subdirectories:    [],
          files:             []
      }
      # Fill in subdirectories and files arrays
      Dir.glob(File.join(path, '*')) do |subpath|
        next if IGNORED_FILES.include?(File.basename(subpath))
        relative_subpath = subpath.delete_prefix(root)
        node_id          = idify(relative_subpath)
        node_uuid        = uuidify(relative_subpath)
        if File.directory?(subpath)
          dir[:subdirectories] << {
              id:   node_id,
              uuid: node_uuid,
              name: File.basename(subpath),
              path: "/cfs_directories/#{node_id}.json",
          }
        else
          dir[:files] << {
              id:                node_id,
              name:              File.basename(subpath),
              md5_sum:           '0' * 32, # do we want to compute this?
              uuid:              node_uuid,
              content_type:      'unknown/unknown',
              size:              File.size(subpath),
              mtime:             DEFAULT_TIME,
              path:              "/cfs_files/#{node_id}.json",
              relative_pathname: relative_subpath[1..-1]
          }
        end
      end
      # Fill in parent directory, if not a root directory of a file group
      path_parts = path.split('/')
      path_parts.pop
      if path_parts[path_parts.length - 2] != 'file_groups'
        parent_path          = path_parts.join('/')
        relative_parent_path = parent_path.delete_prefix(root)
        parent_id            = idify(relative_parent_path)
        dir[:parent_directory] = {
            id:   parent_id,
            name: File.basename(parent_path),
            path: "/cfs_directories/#{parent_id}",
            uuid: uuidify(relative_parent_path)
        }
      end
      return dir
    end
    nil
  end

  def directory_tree(id)
    id = id.to_i
    Dir.glob(File.join(root, '/repositories/*/collections/*/file_groups/*/**/*')) do |root_path|
      relative_root_path = root_path.delete_prefix(root)
      dir_id             = idify(relative_root_path)
      return assemble_tree(root_path) if dir_id == id
    end
    nil
  end

  def file(id)
    id = id.to_i
    Dir.glob(File.join(root, '/repositories/*/collections/*/file_groups/*/root/**/*')) do |path|
      next unless File.file?(path)
      relative_file_path = path.delete_prefix(root)
      file_id            = idify(relative_file_path)
      next unless file_id == id
      file = {
          id:                file_id,
          name:              File.basename(relative_file_path),
          md5_sum:           '0' * 32, # do we want to compute this?
          uuid:              uuidify(relative_file_path),
          content_type:      'unknown/unknown',
          size:              File.size(path),
          mtime:             DEFAULT_TIME,
          relative_pathname: relative_file_path[1..-1]
      }
      parts             = relative_file_path.split('/')
      relative_dir_path = parts[0..parts.length - 2].join('/')
      dir_id            = idify(relative_dir_path)
      file[:directory] = {
          id:   dir_id,
          name: File.basename(relative_dir_path),
          path: "/cfs_directories/#{dir_id}",
          uuid: uuidify(relative_dir_path)
      }
      return file
    end
    nil
  end

  def file_group(id)
    id = id.to_i
    Dir.glob(File.join(root, '/repositories/*/collections/*/file_groups/*')) do |file_group_path|
      parts            = file_group_path.split('/')
      relative_fg_path = file_group_path.delete_prefix(root)
      file_group_id    = parts[parts.length - 1].to_i
      next unless file_group_id == id
      file_group                  = ::YAML.load(File.read(File.join(file_group_path, 'info.yml')))
      file_group['id']            = file_group_id
      file_group['uuid']          = uuidify(relative_fg_path)
      file_group['collection_id'] = parts[parts.length - 3].to_i
      if file_group['storage_level'] == 'bit_level'
        relative_dir_path           = File.join(file_group_path, 'root').delete_prefix(root)
        dir_id                      = idify(relative_dir_path)
        file_group['cfs_directory'] = {
            'id':   dir_id,
            'name': 'root',
            'path': "/cfs_directories/#{dir_id}.json",
            'uuid': uuidify(relative_dir_path)
        }
      end
      return file_group
    end
    nil
  end

  def repositories
    repositories = []
    Dir.glob(File.join(root, 'repositories', '*')) do |repo_path|
      relative_path = repo_path.delete_prefix(root)
      info_path     = File.join(repo_path, 'info.yml')
      if File.exist?(info_path)
        repo = ::YAML.load(File.read(info_path))
      else
        repo = {}
      end
      repo['id']   = relative_path.split('/').last.to_i
      repo['uuid'] = uuidify(relative_path)
      %w(ldap_admin_domain).each { |k| repo.delete(k) }
      repositories << repo
    end
    repositories
  end

  def repository(id)
    id            = id.to_i
    path          = File.join(root, 'repositories', id.to_s)
    relative_path = path.delete_prefix(root)
    info_path     = File.join(path, 'info.yml')
    if File.exist?(info_path)
      repo                = ::YAML.load(File.read(info_path))
      repo['id']          = id
      repo['uuid']        = uuidify(relative_path)
      repo['collections'] = []
      Dir.glob(File.join(path, 'collections/*/info.yml')) do |collection_info_path|
        parts                = collection_info_path.split('/')
        collection           = ::YAML.load(File.read(collection_info_path))
        collection.select!{ |k,v| %w(title).include?(k) }
        collection['id']     = parts[parts.length - 2].to_i
        collection['path']   = "/collections/#{collection['id']}.json"
        repo['collections'] << collection
      end
      %w(notes address_1 address_2 city state zip phone_number).each { |k| repo.delete(k) }
      repo
    else
      nil
    end
  end

  ##
  # @return [String]
  #
  def root
    ENV['REPOSITORY_ROOT'] || File.join(__dir__, '..', 'content')
  end


  private

  def assemble_tree(dir_path)
    relative_path            = dir_path.delete_prefix(root)
    tree                     = {}
    tree[:id]                = idify(relative_path)
    tree[:uuid]              = uuidify(relative_path)
    tree[:name]              = File.basename(relative_path)
    path_parts               = relative_path.split('/')
    path_parts.pop
    parent_relative_path     = path_parts.join('/')
    if parent_relative_path.match?(/file_groups\/\d$/)
      tree[:parent_id]       = path_parts[path_parts.length - 1].to_i
      tree[:parent_type]     = 'FileGroup'
    else
      tree[:parent_id]       = idify(parent_relative_path)
      tree[:parent_type]     = 'CfsDirectory'
    end
    tree[:files]             = []
    tree[:subdirectories]    = []
    tree[:relative_pathname] = relative_path[1..-1]

    Dir.glob(File.join(dir_path, '*')) do |subpath|
      if File.directory?(subpath)
        tree[:subdirectories] << assemble_tree(subpath)
      elsif !IGNORED_FILES.include?(File.basename(subpath))
        relative_subpath = subpath.delete_prefix(root)
        tree[:files] << {
            id:                idify(relative_subpath),
            uuid:              uuidify(relative_subpath),
            name:              File.basename(subpath),
            content_type:      'unknown/unknown',
            md5_sum:           '0' * 32,
            size:              File.size(subpath),
            mtime:             DEFAULT_TIME,
            relative_pathname: relative_subpath[1..-1]
        }
      end
    end
    tree
  end

  ##
  # @return [Integer] Stable integer (<= 2^32) corresponding to the given string.
  #
  def idify(string)
    Digest::MD5.hexdigest(string.delete_prefix(root))[0..7].hex
  end

  ##
  # @return [String] Fake but stable UUID corresponding to the given string.
  #
  def uuidify(string)
    Digest::MD5.hexdigest(string.to_s).
        insert(8, '-').insert(13, '-').insert(18, '-').insert(23, '-')
  end

end
