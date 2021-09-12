class CreateReactions < ActiveRecord::Migration[6.1]
  def up
    create_table :reactions do |t|
      t.references :comment, null: true, foreign_key: true, on_delete: :cascade
      t.references :user, null: false, foreign_key: true, on_delete: :cascade

      t.timestamps
    end

    execute <<-SQL
    ALTER TABLE reactions ADD kind enum('like', 'smile', 'thumbs_up') NOT NULL;
    SQL

    add_index :reactions, [:user_id, :comment_id], unique: true
  end

  def down
    drop_table :reactions
  end
end
