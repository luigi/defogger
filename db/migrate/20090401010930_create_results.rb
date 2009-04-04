class CreateResults < ActiveRecord::Migration
  def self.up
    create_table :results do |t|
      t.string :key
      t.text :source_url, :source_body, :result_body, :api_body
      t.timestamps
    end
  end

  def self.down
    drop_table :results
  end
end
