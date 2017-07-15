class CreateAuthors < ActiveRecord::Migration[5.1]
  def change
    create_table :authors do |t|
      t.string :name
      t.integer :age
      t.string :email

      t.timestamps
    end
  end
end
