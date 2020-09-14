require 'rubygems'
require 'bundler/setup'
require 'json'
require 'sinatra'
require './lib/content_repository'

use Rack::Auth::Basic do |user, secret|
  user == 'medusa' && secret == 'secret'
end

get '/' do
  '<h1>Welcome to Mockdusa</h1>'
end

get /\/repositories/ do
  "All Repositories"
end

get /\/repositories.json/ do
  repos = ContentRepository.new.repositories
  headers 'Content-Type' => 'application/json'
  body JSON.generate(repos)
end

get /\/repositories\/(\d+)/ do
  repo = ContentRepository.new.repository(params['captures'].first)
  if repo
    status 200
    body "Repository #{params['captures'].first}"
  else
    status 404
    body "Not Found"
  end
end

get /\/repositories\/(\d+).json/ do
  repo = ContentRepository.new.repository(params['captures'].first)
  if repo
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(repo)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/collections/ do
  "All Collections"
end

get /\/collections.json/ do
  collections = ContentRepository.new.collections
  headers 'Content-Type' => 'application/json'
  body JSON.generate(collections)
end

get /\/collections\/(\d+)/ do
  collection = ContentRepository.new.collection(params['captures'].first)
  if collection
    status 200
    body "Collection #{params['captures'].first}"
  else
    status 404
    body "Not Found"
  end
end

get /\/collections\/(\d+).json/ do
  collection = ContentRepository.new.collection(params['captures'].first)
  if collection
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(collection)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/file_groups\/(\d+)/ do
  file_group = ContentRepository.new.file_group(params['captures'].first)
  if file_group
    status 200
    body "File group #{params['captures'].first}"
  else
    status 404
    body "Not Found"
  end
end

get /\/file_groups\/(\d+).json/ do
  file_group = ContentRepository.new.file_group(params['captures'].first)
  if file_group
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(file_group)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/cfs_directories\/(\d+)/ do
  dir = ContentRepository.new.directory(params['captures'].first)
  if dir
    status 200
    body "Directory #{params['captures'].first}"
  else
    status 404
    body "Not Found"
  end
end

get /\/cfs_directories\/(\d+).json/ do
  dir = ContentRepository.new.directory(params['captures'].first)
  if dir
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(dir)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/cfs_directories\/(\d+)\/show_tree/ do
  status 406
end

get /\/cfs_directories\/(\d+)\/show_tree.json/ do
  dir = ContentRepository.new.directory_tree(params['captures'].first)
  if dir
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(dir)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/cfs_files\/(\d+)/ do
  file = ContentRepository.new.file(params['captures'].first)
  if file
    status 200
    body "File #{params['captures'].first}"
  else
    status 404
    body "Not Found"
  end
end

get /\/cfs_files\/(\d+).json/ do
  file = ContentRepository.new.file(params['captures'].first)
  if file
    status 200
    headers 'Content-Type' => 'application/json'
    body JSON.generate(file)
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end

get /\/uuids\/([a-z0-9-]+)/ do
  path = ContentRepository.new.path_for_uuid(params['captures'].first)
  if path
    redirect path, 302
  else
    status 404
    body "Not Found"
  end
end

get /\/uuids\/([a-z0-9-]+).json/ do
  path = ContentRepository.new.path_for_uuid(params['captures'].first)
  if path
    redirect "#{path}.json", 302
  else
    status 404
    headers 'Content-Type' => 'application/json'
    body JSON.generate({ 'status': 404, 'error': "Not Found" })
  end
end
