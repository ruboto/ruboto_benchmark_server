class CreateStartups < ActiveRecord::Migration
  def self.up
    create_table :startups do |t|
      t.integer :startup_time, :null => false
      t.string :package, :null => false
      t.string :package_version, :null => false
      t.string :manufacturer, :null => false
      t.string :device, :null => false
      t.string :android_version, :null => false
      t.string :ruboto_platform_version, :null => false
      t.string :ruboto_app_version, :null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :startups
  end
end
