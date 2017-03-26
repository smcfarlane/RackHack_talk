Sequel.migration do
  change do
    create_table :movies do
      primary_key :id
      String :title
      String :description, text: true
      DateTime :created_at
      DateTime :updated_at
    end
  end
end
