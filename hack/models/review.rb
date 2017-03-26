require 'sequel'

class Review < Sequel::Model
  many_to_one :user
  many_to_one :movie
end
