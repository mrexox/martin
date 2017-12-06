class CreateAdmins < ActiveRecord::Migration
  def up
    create_table :admins do |t|
      t.string :login
      t.string :password_digest
    end
  end

  def down
      drop_table :admins
  end
end
