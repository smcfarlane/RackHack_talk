require 'sequel'
require 'bcrypt'

class User < Sequel::Model
  include BCrypt
  one_to_many :reviews

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def to_h
    {
      name: name,
      email: email,
      signed_in: signed_in
    }
  end
end
