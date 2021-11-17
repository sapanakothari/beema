# frozen_string_literal: true

class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles do |t|
      t.references :customer, null: false, foreign_key: { on_delete: :cascade }
      t.string :model, null: false, index: { unique: false }
      t.integer :year, null: false
      t.bigint :chassis_number, null: false, index: { unique: true }
      t.string :color
      t.date :registration_date
      t.uuid :batch_id
      t.timestamps
    end
  end
end
