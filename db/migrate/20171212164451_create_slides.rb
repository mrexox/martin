class CreateSlides < ActiveRecord::Migration
  def up
    create_table :slides do |t|
      t.string :photo
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end

	def down
		drop_table :slides
	end
end
