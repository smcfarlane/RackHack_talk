Sequel.migration do
  change do
    create_table :reviews do
      primary_key :id
      String :title
      String :body, text: true
      Integer :stars
      DateTime :created_at
      DateTime :updated_at
      foreign_key :user_id, :users
      foreign_key :movie_id, :movies
    end
  end
end
