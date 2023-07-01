ActiveRecord::Schema.define(:version => 1) do

  create_table :abstract_posts do |t|
    t.jsonb :title
    t.jsonb :body
    t.string :name
    t.integer :void, :default => 1
  end

  create_table :named_posts do |t|
    t.jsonb :title
    t.string :name
  end

end
