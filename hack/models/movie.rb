require 'sequel'

class Movie < Sequel::Model
  one_to_many :reviews
end
