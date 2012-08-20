class RenameFib20 < ActiveRecord::Migration
  def self.up
    execute "UPDATE measurements SET test = 'Fibonacci, n=20' WHERE test = 'Fibonacci , n=20'"
  end

  def self.down
  end
end
