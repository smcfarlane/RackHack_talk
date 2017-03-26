require 'rubygems'
require 'bundler/setup'
require 'pry'
require 'sinatra'
require 'json'
require 'sequel'
require 'hamlit'
require_relative '../db/config'
DB = Sequel.connect(Database.url('dev'))

require_relative 'models/movie'
require_relative 'models/review'
require_relative 'models/user'

module Hack
  class App < Sinatra::Base
    attr_accessor :current_user
    enable :sessions
    set :views, './hack/templates'
    set :haml, escape_html: false
    set :session_secret, 'aklvmkjnsdsakljeroiwnvkdnlasdlkfjaskgbndklsflakjsfgkljdflkjssdf'

    before do
      @current_user = User[session['user_id']] if session['user_id']
      @spam_count = request.env.fetch('spam_count', 0)
    end

    get '/' do
      @movies = Movie.all
      haml :home
    end

    get '/movies/new' do
      haml :movies_new
    end

    post '/movies' do
      @movie = Movie.create(params['movie'])
      redirect to('/')
    end

    get '/movies/:movie_id' do
      @movie = Movie[params['movie_id']]
      haml :movie
    end

    post '/movies/:movie_id/reviews' do
      @movie = Movie[params['movie_id']]
      Review.create(params['review'].merge(movie_id: params['movie_id']))
      redirect to("/movies/#{@movie.id}")
    end

    get '/movies/:movie_id/reviews/:id' do
      Review[params['id']].destroy
      redirect to("/movies/#{params['movie_id']}")
    end

    get '/sign-in' do
      haml :sign_in
    end

    post '/sign-in' do
      @user = User.where(email: params['user']['email']).first
      redirect to('/sign-in') unless @user
      if @user.password = params['user']['password']
        session['user_id'] = @user.id
      end
      redirect to('/')
    end

    get '/sign-out' do
      redirect to('/')
    end

    get '/sign-up' do
      haml :sign_up
    end

    post '/sign-up' do
      @user = User.create(params['user'])
      session['user_id'] = @user.id
      redirect to('/')
    end

    get '/log' do
      @log_data = File.read('./log/app.log')
      haml :log
    end

    get '/for/spammers' do
      haml :spammers
    end
  end
end
