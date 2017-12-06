class CreateMessages < ActiveRecord::Migration
  def up
    create_table :messages do |t|
      t.string :name
      t.string :company_name
      t.string :email
      t.string :telephone
      t.integer :type_of_order
      t.text :comment

      t.timestamps null: false
    end
  end

  def down
      drop_table :messages
  end
end
