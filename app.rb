require 'sinatra'
require 'sinatra/activerecord'
require 'sinatra/flash'
require 'omniauth-github'

require_relative 'config/application'

Dir['app/**/*.rb'].each { |file| require_relative file }

helpers do
  def current_user
    user_id = session[:user_id]
    @current_user ||= User.find(user_id) if user_id.present?
  end

  def signed_in?
    current_user.present?
  end
end

def set_current_user(user)
  session[:user_id] = user.id
end

def authenticate!
  unless signed_in?
    flash[:notice] = 'You need to sign in if you want to do that!'
    redirect '/'
  end
end

get '/' do
  @meetups = Meetup.all.order(:name)
  erb :index
end

get '/meetups/new' do
  authenticate!
  erb :'meetups/new'
end

post '/meetups' do
  meetup = Meetup.create(name: params[:name], description: params[:description], location: params[:location])
  if !meetup.errors.empty?
    flash[:error] = meetup.errors.full_messages
    redirect "/meetups/new"
  else
    flash[:notice] = "You successfully created a new meetup!"
    redirect "/meetups/#{meetup.id}"
  end
end

get '/meetups/:id' do
  @meetup = Meetup.find(params[:id])
  @comments = Comment.where(meetup_id: params[:id])
  erb :'meetups/show'
end

post '/meetups/:id/comment' do
  meetup = Meetup.find(params[:id])
  user = current_user

  @user_id = []
  meetup.users.each do |o|
    @user_id << o.id
  end

  if !signed_in?
    authenticate!
  end
  if signed_in? && !@user_id.include?(user.id)
    flash[:notice] = "You must join this meetup to comment."
    redirect "/meetups/#{meetup.id}"
  end

  comment = Comment.create(title: params[:title], body: params[:body], user_id: user.id, meetup_id: meetup.id)

  if signed_in? && !comment.errors.empty?
    flash[:error] = comment.errors.full_messages
    redirect "/meetups/#{meetup.id}"
  elsif signed_in?
    flash[:notice] = "You successfully posted a comment"
    redirect "/meetups/#{meetup.id}"
  end
end

post '/meetups/:id/join' do
  meetup = Meetup.find(params[:id])
  user = current_user
  if signed_in?
    join = MeetupsUser.create(user_id: user.id, meetup_id: meetup.id)
    flash[:notice] = "You joined this meetup!"
    redirect "/meetups/#{meetup.id}"
  else
    authenticate!
  end
end

post '/meetups/:id/leave' do
  meetup = Meetup.find(params[:id])
  user = current_user
  leave = meetup.users.destroy(user.id)
  flash[:notice] = "You left this meetup!"
  redirect "/meetups/#{meetup.id}"
end

get '/auth/github/callback' do
  auth = env['omniauth.auth']

  user = User.find_or_create_from_omniauth(auth)
  set_current_user(user)
  flash[:notice] = "You're now signed in as #{user.username}!"

  redirect '/'
end

get '/sign_out' do
  session[:user_id] = nil
  flash[:notice] = "You have been signed out."

  redirect '/'
end

get '/example_protected_page' do
  authenticate!
end
