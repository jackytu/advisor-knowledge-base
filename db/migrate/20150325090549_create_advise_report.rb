class CreateAdviseReport < ActiveRecord::Migration
  def up
    create_table :advise_reports do |t|
      t.string :appname
      t.integer :advise
      t.integer :quota
      t.integer :usage
      t.string :report_type
      t.timestamp
    end
  end

  def down
  end
end
