class CreatePosts < ActiveRecord::Migration[5.0]
    def up
      create_table :posts do |t|
        t.integer :user_id
        t.string :title
        t.string :body
      end
    end

    def down
      drop_table :posts
    end
  end