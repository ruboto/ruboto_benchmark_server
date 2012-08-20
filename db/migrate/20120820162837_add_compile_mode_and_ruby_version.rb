class AddCompileModeAndRubyVersion < ActiveRecord::Migration
  def self.up
    add_column :measurements, :compile_mode, :string, :limit => 8
    add_column :measurements, :ruby_version, :string, :limit => 8
    execute "UPDATE measurements SET ruboto_platform_version = '0.4.8.dev' WHERE ruboto_platform_version = '0.4.8'"

    execute "UPDATE measurements SET compile_mode = 'OFF' WHERE compile_mode IS NULL AND NOT test LIKE '%OFFIR%'"
    execute "UPDATE measurements SET compile_mode = 'OFFIR' WHERE compile_mode IS NULL"

    execute "UPDATE measurements SET ruby_version = 'RUBY1_9' WHERE
                    ruboto_platform_version = '0.4.8.dev'
                 OR ruboto_platform_version = 'JRuby 1.7.0.preview2'
                 OR test LIKE '%RUBY1_9%'"
    execute "UPDATE measurements SET ruby_version = 'RUBY1_8' WHERE ruby_version IS NULL"
    Measurement.all.each do |m|
      if m.test =~ /(.*) OFF(?:IR)?(.*)/
        m.test = "#$1#$2"
      end
      if m.test =~ /(.*) RUBY1_[89](.*)/
        m.test = "#$1#$2"
      end
      m.save!
    end
  end

  def self.down
    remove_column :measurements, :ruby_version
    remove_column :measurements, :compile_mode
  end

  class Measurement < ActiveRecord::Base ; end
end
