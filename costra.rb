#!ruby
#-*- coding: utf-8 -*-
require 'sinatra'
require 'sequel'
require 'haml'
require 'logger'
require 'sinatra/reloader'
require 'yaml'

Config = YAML.load(open('./config.yaml').read)
Sequel::Model.plugin(:schema)
DB = Sequel.connect(Config["db"])
DB.loggers << Logger.new($stderr) if Config["debug"]

require './model/order'
require './model/cost'
require './model/user'

#load './model/cost.rb'

#set :sessions, true
#set :environment, :no_test

get '/' do
  @orders = Order.order_by(:id.desc)
  haml :home
end

get '/order/:id' do
  @order = Order.find(:id => params[:id])
  @cost  = Cost.new
  @users = User.find_all
  haml :order
end

post '/order' do
  Order.create(
    :name     => params[:name] ,
    :code     => params[:code] ,
    :amount   => params[:amount] ,
    :from     => Date.parse(params[:from]),
    :to       => Date.parse(params[:to])
  )
  redirect '/'
end

##
#
#
get '/order/cost/:id' do
  @cost  = Cost.find(:id => params[:id])
  @users = User.find_all
  haml :cost
end

post '/order/cost/:id' do
  Cost.create(params[:cost]);
  redirect '/order/' + params[:id]
end

put '/order/cost/:id' do
  cost = Cost.find(:id => params[:id])
  cost.update(params[:cost])
  redirect "/order/#{cost.order_id}"
end


delete '/order/cost/:id' do
  Cost.find(:id => params[:id]).delete
  redirect '/order/' + params[:order_id]
end

helpers do
  include Rack::Utils; alias_method :h, :escape_html

  def partial(renderer, template, options = {})
    options = options.merge({:layout => false})
    template = "_#{template.to_s}".to_sym
    m = method(renderer)
    m.call(template, options)
  end

  def partial_haml(template, options = {})
    partial(:haml, template, options)
  end

  def partial_erb(template, options)
    partial(:erb, template, options)
  end
end
