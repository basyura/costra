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

put '/order/:id' do
  order = Order.find(params[:id])
  order.update(params[:order])
  redirect "/order/#{order.id}"
end

get '/order/edit/:id' do
  @order = Order.find(:id => params[:id])
  haml :order_edit
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
  puts params[:cost]
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

##
#
#
get '/user' do
  @users = User.find_all
  haml :user_list
end

post '/user' do
  User.create(params[:user])
  redirect '/user'
end



get '/user/:id' do
  @user  = User.find(:id => params[:id])
  @user  = User.find(:name => params[:id]) unless @user
  @costs = Cost.filter(:user_id => @user.id)

  haml :user
end

get '/user/:id/edit' do
  @user = User.find(:id => params[:id])
  haml :user_edit
end

put '/user/:id' do
  user = User.find(:id => params[:id])
  user.update(params[:user])
  redirect "/user/#{params[:id]}"
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
