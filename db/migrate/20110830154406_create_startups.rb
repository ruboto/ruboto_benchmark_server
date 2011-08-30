class CreateStartups < ActiveRecord::Migration
  def self.up
    create_table :startups do |t|
      t.string :package
      t.string :manufacturer
      t.string :device
      t.string :android_version
      t.string :ruboto_platform_version
      t.string :ruboto_app_version
      t.string :app_version

      t.timestamps
    end
  end

  def self.down
    drop_table :startups
  end
end
