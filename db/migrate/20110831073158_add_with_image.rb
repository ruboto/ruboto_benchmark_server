class AddWithImage < ActiveRecord::Migration
  def change
    add_column :startups, :with_image, :boolean
    execute 'UPDATE startups SET with_image = TRUE'
    change_column :startups, :with_image, :boolean, null: false
  end
end
