class GeneralizeBenchmarking < ActiveRecord::Migration
  def self.up
    rename_table :startups, :measurements
    rename_column :measurements, :startup_time, :duration
    add_column :measurements, :test, :string, limit: 32
    execute "UPDATE measurements SET test = 'Startup' WHERE with_image = 'f'"
    execute "UPDATE measurements SET test = 'Startup with image' WHERE with_image = 't'"
    change_column_null :measurements, :test, false
    remove_column :measurements, :with_image
  end

  def self.down
    raise 'Not implemented, yet!'
  end
end
