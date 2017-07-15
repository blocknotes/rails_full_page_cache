class CreateDetails < ActiveRecord::Migration[5.1]
  def change
    create_table :details do |t|
      t.text :description
      t.belongs_to :author, foreign_key: true

      t.timestamps
    end
  end
end
