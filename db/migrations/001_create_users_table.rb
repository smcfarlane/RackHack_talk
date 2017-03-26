Sequel.migration do
  change do
    create_table :users do
      primary_key :id, type: :Bignum
      String :name
      String :email
      String :password_hash
      Boolean :signed_in
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
