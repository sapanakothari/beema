# frozen_string_literal: true

class CreateOdometerReadings < ActiveRecord::Migration[7.0]
  def change
    create_table :odometer_readings do |t|
      t.references :vehicle, null: false, foreign_key: { on_delete: :cascade }
      t.integer :value, null: false
      t.timestamps
    end
  end
end
