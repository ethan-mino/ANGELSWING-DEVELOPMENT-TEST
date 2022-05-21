class CreateProjects < ActiveRecord::Migration[6.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false
      t.text :description, null: true
      t.integer :type, null: false
      t.string :location, null: false
      t.text :thumbnail, null: false
      t.references :user, null: false, foreign_key: true
	  t.index [:id, :title], unique: true
	
      t.timestamps
    end
  end
end
