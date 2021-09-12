class AddCascadeFksToPost < ActiveRecord::Migration[6.1]
  def change
    remove_foreign_key :comments, :posts
    remove_foreign_key :comments, :users
    add_foreign_key :comments, :posts, on_delete: :cascade
    add_foreign_key :comments, :users, on_delete: :cascade
  end
end
