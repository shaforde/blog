require 'sinatra'
require "sinatra/reloader"

# Run this script with `bundle exec ruby app.rb`
require 'active_record'

#require model classes
# require './models/cake.rb'
require './models/user.rb'
require './models/post.rb'

# Use `binding.pry` anywhere in this script for easy debugging
require 'pry'
require 'csv'
require 'flash'
require 'sinatra/flash'

# Connect to a sqlite3 database
# If you feel like you need to reset it, simply delete the file sqlite makes
if ENV['DATABASE_URL']
  require 'pg'
  # use DATABASE_URL since this is Heroku
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  # Use sqlite since this is my computer
  require 'sqlite3'
  ActiveRecord::Base.establish_connection(
    adapter: 'sqlite3',
    database: 'db/development.db'
  )
end

register Sinatra::Reloader
enable :sessions

get '/' do
  erb :index
end
get '/user/profile' do
  erb :profile
end

get '/user/account' do
  erb :account
end

get '/home' do
  erb :home
end

get '/' do
  if session[:user_id]
    @user=User.find(session[:user_id])
    erb :profile
  else
    flash[:alert] = 'If you have not created an account please <a href="/">sign up</a>. If you have already created an account please go back to our <a href="/">login</a> page and ensure  your password is correct.'
    erb :error
  end
end




post '/signup' do
  temp_user = User.find_by(email: params["email"])
  if temp_user
    flash[:alert] = 'Please <a href="/">login</a>'
    erb :error
  else
    user = User.create(email: params[name="email"], password: params[name="password"], first_name: params[name="first_name"], last_name: params[name="last_name"], birthday: params[name="birthday"] )
    session[:user_id] = user.id
    redirect "/user/profile"
  end
end

post '/login' do
  user = User.find_by(email: params["email"], password: params["password"])
  if !user
    flash[:alert] = 'If you have not created an account please <a href="/">sign up</a>. If you have already created an account please go back to our <a href="/">login</a> page and ensure  your password is correct.'
    erb :error
  else
    session[:user_id] = user.id
    redirect "/user/profile"
  end
end

post '/logout' do
  session[:user_id] = nil
  redirect '/'
end

get '/cancel' do
  des_user=User.find(session[:user_id])
  session[:user_id] = nil
  des_user.destroy
  redirect '/'
end

post '/add' do
 Post.create(title: params["title"], body: params["body"], user_id: session[:user_id])
 if session[:user_id]
     Post.all.reverse
    erb :profile
  redirect '/user/profile'
  end
end


