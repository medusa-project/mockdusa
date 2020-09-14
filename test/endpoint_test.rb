require 'test_helper'
require_relative '../main'

class RequestHandlerTest < Minitest::Test
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
                'title' => 'Some Collection',
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
        'title' => 'Some Collection',
        'description' => 'Lorem ipsum dolor sit amet',
        'description_html' => '<p>Lorem ipsum dolor sit amet</p>',
        'access_url' => 'https://example.org/',
        'physical_collection_url' => nil,
        'publish' => true,
        'representative_image' => nil,
        'representative_item' => nil,
        'external_id' => nil,
        'contact_email' => 'alexd@illinois.edu',
        'private_description' => nil,
        'id' => 1,
        'uuid' => '81a13f45-d149-3dd7-f233-53cc395217fa',
        'repository_path' => '/repositories/1',
        'repository_title' => 'Mockdusa Test Repository',
        'repository_uuid' => '40b62a2d-209f-292a-b1fc-4818b3321e6a',
        'file_groups' => [
            {
                'title' => 'Content',
                'storage_level' => 'bit_level',
                'id' => 1,
                'path' => '/file_groups/1.json'
            }
        ]
    }
    assert_equal expected, JSON.parse(last_response.body)
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

  def test_file_group_json
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

  def test_directory_json
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
    # convert arrays into sets for unordered equality
    expected['subdirectories'] = Set.new(expected['subdirectories'])
    expected['files']          = Set.new(expected['files'])
    actual                   = JSON.parse(last_response.body)
    actual['subdirectories'] = Set.new(actual['subdirectories'])
    actual['files']          = Set.new(actual['files'])
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

  def headers(options = {})
    { 'HTTP_AUTHORIZATION' => "Basic " + Base64::encode64("medusa:secret") }
  end

end