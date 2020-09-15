require 'test_helper'
require_relative '../main'

class EndpointTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  # /

  def test_landing_page
    get '/', nil, headers
    assert_equal 200, last_response.status
  end

  # /repositories

  def test_repositories_without_authentication
    get '/repositories'
    assert_equal 401, last_response.status
  end

  def test_repositories_html
    get '/repositories', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'All Repositories', last_response.body
  end

  def test_repositories_json
    get '/repositories.json', nil, headers
    assert_equal 200, last_response.status
    actual = JSON.parse(last_response.body)
    actual.sort_by!{ |k| k['id'] }
    assert_equal 2, actual.length
    expected = {
        'title'             => 'Mockdusa Test Repository',
        'url'               => 'https://github.com/medusa-project/mockdusa',
        'notes'             => 'This repository contains Mockdusa test content.',
        'address_1'         => '123 Anywhere St.',
        'address_2'         => 'Room 422',
        'city'              => 'Urbana',
        'state'             => 'IL',
        'zip'               => 61820,
        'phone_number'      => '(555) 555-5555',
        'contact_email'     => 'alexd@illinois.edu',
        'email'             => 'alexd@illinois.edu',
        'ldap_admin_group'  => 'Some Group',
        'id'                => 1,
        'uuid'              => '40b62a2d-209f-292a-b1fc-4818b3321e6a'
    }
    assert_equal expected, actual[0]
  end

  # /repositories/:id

  def test_repository_without_authentication
    get '/repositories/1'
    assert_equal 401, last_response.status
  end

  def test_invalid_repository_html
    get '/repositories/99999', nil, headers
    assert_equal 404, last_response.status
  end

  def test_invalid_repository_json
    get '/repositories/99999.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_repository_html
    get '/repositories/1', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'Repository 1', last_response.body
  end

  def test_repository_json
    get '/repositories/1.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'title'             => 'Mockdusa Test Repository',
        'url'               => 'https://github.com/medusa-project/mockdusa',
        'contact_email'     => 'alexd@illinois.edu',
        'email'             => 'alexd@illinois.edu',
        'ldap_admin_domain' => 'uofi',
        'ldap_admin_group'  => 'Some Group',
        'id'                => 1,
        'uuid'              => '40b62a2d-209f-292a-b1fc-4818b3321e6a',
        'collections'       => [
            {
                'title' => 'Mockdusa Test Collection',
                'id'    => 1,
                'path'  =>'/collections/1.json'
            }
        ]
    }
    assert_equal expected, JSON.parse(last_response.body)
  end

  # /collections

  def test_collections_without_authentication
    get '/collections'
    assert_equal 401, last_response.status
  end

  def test_collections_html
    get '/collections', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'All Collections', last_response.body
  end

  def test_collections_json
    get '/collections.json', nil, headers
    assert_equal 200, last_response.status
    actual = JSON.parse(last_response.body)
    actual.sort_by!{ |k| k['id'] }
    assert_equal 2, actual.length
    expected = {
        'id'   => 1,
        'uuid' => '81a13f45-d149-3dd7-f233-53cc395217fa',
        'path' => '/collections/1'
    }
    assert_equal expected, actual[0]
  end

  # /collections/:id

  def test_collection_without_authentication
    get '/collections/99999'
    assert_equal 401, last_response.status
  end

  def test_invalid_collection_html
    get '/collections/99999', nil, headers
    assert_equal 404, last_response.status
  end

  def test_invalid_collection_json
    get '/collections/99999.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_collection_html
    get '/collections/1', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'Collection 1', last_response.body
  end

  def test_collection_json
    get '/collections/1.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'title'                   => 'Mockdusa Test Collection',
        'description'             => 'This collection contains Mockdusa test content.',
        'description_html'        => '<p>This collection contains Mockdusa test content.</p>',
        'access_url'              => 'https://example.org/',
        'physical_collection_url' => nil,
        'publish'                 => true,
        'representative_image'    => nil,
        'representative_item'     => nil,
        'external_id'             => nil,
        'contact_email'           => 'alexd@illinois.edu',
        'private_description'     => nil,
        'id'                      => 1,
        'uuid'                    => '81a13f45-d149-3dd7-f233-53cc395217fa',
        'repository_path'         => '/repositories/1',
        'repository_title'        => 'Mockdusa Test Repository',
        'repository_uuid'         => '40b62a2d-209f-292a-b1fc-4818b3321e6a',
        'file_groups'             => [
            {
                'title'         => 'Content',
                'storage_level' => 'bit_level',
                'id'            => 1,
                'path'          => '/file_groups/1.json'
            },
            {
                'title'         => 'External Content',
                'storage_level' => 'external',
                'id'            => 2,
                'path'          => '/file_groups/2.json'
            }
        ]
    }
    actual = JSON.parse(last_response.body)
    convert_arrays_to_sets(expected)
    convert_arrays_to_sets(actual)
    assert_equal expected, actual
  end

  # /file_groups/:id

  def test_file_group_authentication
    get '/file_groups/99999'
    assert_equal 401, last_response.status
  end

  def test_invalid_file_group_html
    get '/file_groups/99999', nil, headers
    assert_equal 404, last_response.status
  end

  def test_invalid_file_group_json
    get '/file_groups/99999.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_file_group_html
    get '/file_groups/1', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'File group 1', last_response.body
  end

  def test_file_group_json_with_bit_level_file_group
    get '/file_groups/1.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'title'                  => 'Content',
        'external_file_location' => nil,
        'storage_level'          => 'bit_level',
        'id'                     => 1,
        'uuid'                   => '5881d456-6dbe-90f1-ac81-7e0bf53e9c84',
        'collection_id'          => 1,
        'cfs_directory'          => {
            'id'   => 30193726375172,
            'name' => 'root',
            'path' => '/cfs_directories/30193726375172.json',
            'uuid' => '1b760655-c504-7fce-f171-76e4234844da',
        }
    }
    assert_equal expected, JSON.parse(last_response.body)
  end

  def test_file_group_json_with_external_file_group
    get '/file_groups/2.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'title'                  => 'External Content',
        'external_file_location' => '\\\\\\\\example.org\\\\Files',
        'storage_level'          => 'external',
        'id'                     => 2,
        'uuid'                   => 'bda7c8a5-4e8a-8771-5b3c-5dc51ab75c0c',
        'collection_id'          => 1
    }
    assert_equal expected, JSON.parse(last_response.body)
  end

  # /cfs_directories/:id

  def test_directory_without_authentication
    get '/cfs_directories/99999'
    assert_equal 401, last_response.status
  end

  def test_invalid_directory_html
    get '/cfs_directories/99999', nil, headers
    assert_equal 404, last_response.status
  end

  def test_invalid_directory_json
    get '/cfs_directories/99999.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_directory_html
    get '/cfs_directories/30193726375172', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'Directory 30193726375172', last_response.body
  end

  def test_directory_json_of_file_group_root_directory
    get '/cfs_directories/30193726375172.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'id'                => 30193726375172,
        'uuid'              => '1b760655-c504-7fce-f171-76e4234844da',
        'name'              => 'root',
        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root',
        'subdirectories'    => [
            {
                'id'   => 175789411019744,
                'uuid' => '9fe12966-2be0-e43d-fe3b-8bbbe3c99c90',
                'name' => 'empty_dir',
                'path' => '/cfs_directories/175789411019744.json'
            },
            {
                'id'   => 118181527816155,
                'uuid' => '6b7c47fc-07db-ec4e-9ee8-c87f60611b6a',
                'name' => 'subdir',
                'path' => '/cfs_directories/118181527816155.json'
            }
        ],
        'files' => [
            {
                'id'                => 240067872391336,
                'name'              => 'escher_lego.jpg',
                'md5_sum'           => '00000000000000000000000000000000',
                'uuid'              => 'da572841-80a8-86fb-48eb-6ba18ade48ef',
                'content_type'      => 'unknown/unknown',
                'size'              => 28399,
                'mtime'             => '2020-01-01T10:05:30Z',
                'path'              => '/cfs_files/240067872391336.json',
                'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root'
            }
        ]
    }
    actual = JSON.parse(last_response.body)
    # convert arrays into sets for unordered equality
    convert_arrays_to_sets(expected)
    convert_arrays_to_sets(actual)
    assert_equal expected, actual
  end

  def test_directory_json_of_subdirectory
    get '/cfs_directories/175789411019744.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'id'                => 175789411019744,
        'uuid'              => '9fe12966-2be0-e43d-fe3b-8bbbe3c99c90',
        'name'              => 'empty_dir',
        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/empty_dir',
        'subdirectories'    => [],
        'files' => [],
        'parent_directory' => {
            'id'   => 30193726375172,
            'name' => 'root',
            'path' => '/cfs_directories/30193726375172',
            'uuid' => '1b760655-c504-7fce-f171-76e4234844da'
        }
    }
    actual = JSON.parse(last_response.body)
    # convert arrays into sets for unordered equality
    convert_arrays_to_sets(expected)
    convert_arrays_to_sets(actual)
    assert_equal expected, actual
  end

  # /cfs_directories/:id/show_tree

  def test_directory_tree_without_authentication
    get '/cfs_directories/99999/show_tree'
    assert_equal 401, last_response.status
  end

  def test_invalid_directory_tree_json
    get '/cfs_directories/99999/show_tree.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_directory_tree_html
    get '/cfs_directories/30193726375172/show_tree', nil, headers
    assert_equal 406, last_response.status
  end

  def test_directory_tree_json
    get '/cfs_directories/30193726375172/show_tree.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'id'          => 30193726375172,
        'uuid'        => '1b760655-c504-7fce-f171-76e4234844da',
        'name'        => 'root',
        'parent_id'   => 1,
        'parent_type' => 'FileGroup',
        'files'       => [
            {
                'id'                => 240067872391336,
                'uuid'              => 'da572841-80a8-86fb-48eb-6ba18ade48ef',
                'name'              => 'escher_lego.jpg',
                'content_type'      => 'unknown/unknown',
                'md5_sum'           => '00000000000000000000000000000000',
                'size'              => 28399,
                'mtime'             => '2020-01-01T10:05:30Z',
                'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/escher_lego.jpg'
            }
        ],
        'subdirectories' => [
            {
                'id'                => 175789411019744,
                'uuid'              => '9fe12966-2be0-e43d-fe3b-8bbbe3c99c90',
                'name'              => 'empty_dir',
                'parent_id'         => 30193726375172,
                'parent_type'       => 'CfsDirectory',
                'files'             => [],
                'subdirectories'    => [],
                'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/empty_dir'
            },
            {
                'id'             => 118181527816155,
                'uuid'           => '6b7c47fc-07db-ec4e-9ee8-c87f60611b6a',
                'name'           => 'subdir',
                'parent_id'      => 30193726375172,
                'parent_type'    => 'CfsDirectory',
                'files'          => [
                    {
                        'id'                => 242962082129794,
                        'uuid'              => 'dcf90499-6782-824c-5283-2ce30cdd42ae',
                        'name'              => 'hello.txt',
                        'content_type'      => 'unknown/unknown',
                        'md5_sum'           => '00000000000000000000000000000000',
                        'size'              => 11,
                        'mtime'             => '2020-01-01T10:05:30Z',
                        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/subdir/hello.txt'
                    },
                    {
                        'id'                => 14635739342178,
                        'uuid'              => '0d4fa60b-6562-5fd5-27f2-5e25476945bf',
                        'name'              => 'hello2.txt',
                        'content_type'      => 'unknown/unknown',
                        'md5_sum'           => '00000000000000000000000000000000',
                        'size'              => 17,
                        'mtime'             => '2020-01-01T10:05:30Z',
                        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/subdir/hello2.txt'
                    }
                ],
                'subdirectories' => [
                    {
                        'id'                => 203392051844673,
                        'uuid'              => 'b8fbe700-1641-be76-0aad-a3d62a1ec6f0',
                        'name'              => 'sub_subdir',
                        'parent_id'         => 118181527816155,
                        'parent_type'       => 'CfsDirectory',
                        'files'             => [
                            {
                                'id'                => 130619876552293,
                                'uuid'              => '76cc4f57-ae65-0600-c6ff-e5b199472deb',
                                'name'              => 'hello3.txt',
                                'content_type'      => 'unknown/unknown',
                                'md5_sum'           => '00000000000000000000000000000000',
                                'size'              => 21,
                                'mtime'             => '2020-01-01T10:05:30Z',
                                'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/subdir/sub_subdir/hello3.txt'
                            }
                        ],
                        'subdirectories'    => [],
                        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/subdir/sub_subdir'
                    }
                ],
                'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/subdir'
            }
        ],
        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root'
    }
    actual = JSON.parse(last_response.body)
    # convert arrays into sets for unordered equality
    convert_arrays_to_sets(expected)
    convert_arrays_to_sets(actual)
    assert_equal expected, actual
  end

  # /cfs_files/:id

  def test_file_without_authentication
    get '/cfs_files/99999'
    assert_equal 401, last_response.status
  end

  def test_invalid_file_html
    get '/cfs_files/99999', nil, headers
    assert_equal 404, last_response.status
  end

  def test_invalid_file_json
    get '/cfs_files/99999.json', nil, headers
    assert_equal 404, last_response.status
  end

  def test_file_html
    get '/cfs_files/240067872391336', nil, headers
    assert_equal 200, last_response.status
    assert_equal 'File 240067872391336', last_response.body
  end

  def test_file_json
    get '/cfs_files/240067872391336.json', nil, headers
    assert_equal 200, last_response.status
    expected = {
        'id'                => 240067872391336,
        'name'              => 'escher_lego.jpg',
        'md5_sum'           => '00000000000000000000000000000000',
        'uuid'              => 'da572841-80a8-86fb-48eb-6ba18ade48ef',
        'content_type'      => 'unknown/unknown',
        'size'              => 28399,
        'mtime'             => '2020-01-01T10:05:30Z',
        'relative_pathname' => 'repositories/1/collections/1/file_groups/1/root/escher_lego.jpg',
        'directory'         => {
            'id'   => 30193726375172,
            'name' => 'root',
            'path' => '/cfs_directories/30193726375172',
            'uuid' => '1b760655-c504-7fce-f171-76e4234844da'
        }
    }
    assert_equal expected, JSON.parse(last_response.body)
  end

  # /uuids/:uuid

  def test_uuids_without_authentication
    get '/uuids/40b62a2d-209f-292a-b1fc-4818b3321e6a'
    assert_equal 401, last_response.status
  end

  def test_uuids_with_invalid_uuid
    get '/uuids/00000000-0000-0000-0000-000000000000', nil, headers
    assert_equal 404, last_response.status
  end

  def test_uuids_preserves_format_extension
    get '/uuids/40b62a2d-209f-292a-b1fc-4818b3321e6a.json', nil, headers
    assert_equal 'http://example.org/repositories/1.json',
                 last_response.location
  end

  def test_uuids_with_repository_uuid
    get '/uuids/40b62a2d-209f-292a-b1fc-4818b3321e6a', nil, headers
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/repositories/1', last_response.location
  end

  def test_uuids_with_collection_uuid
    get '/uuids/81a13f45-d149-3dd7-f233-53cc395217fa', nil, headers
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/collections/1', last_response.location
  end

  def test_uuids_with_file_group_uuid
    get '/uuids/5881d456-6dbe-90f1-ac81-7e0bf53e9c84', nil, headers
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/file_groups/1', last_response.location
  end

  def test_uuids_with_directory_uuid
    get '/uuids/1b760655-c504-7fce-f171-76e4234844da', nil, headers
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/cfs_directories/30193726375172',
                 last_response.location
  end

  def test_uuids_with_file_uuid
    get '/uuids/da572841-80a8-86fb-48eb-6ba18ade48ef', nil, headers
    assert_equal 302, last_response.status
    assert_equal 'http://example.org/cfs_files/240067872391336',
                 last_response.location
  end


  private

  def convert_arrays_to_sets(hash)
    return unless hash.kind_of?(Hash)
    hash.keys.each do |key|
      if hash[key].kind_of?(Array)
        hash[key].each do |element|
          convert_arrays_to_sets(element)
        end
        hash[key] = Set.new(hash[key])
      else
        convert_arrays_to_sets(hash[key])
      end
    end
  end

  def headers(options = {})
    { 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("medusa:secret") }
  end

end