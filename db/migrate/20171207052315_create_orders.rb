class CreateOrders < ActiveRecord::Migration
	def change
		create_table :orders do |t|
			t.string :photo, null: false
			t.string :name, null: false
			t.text :response
			t.string :site_href
			t.text :comment1
			t.text :comment2
			t.timestamps null: false
		end
	end
end
