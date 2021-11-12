# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_10_130238) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'customers', force: :cascade do |t|
    t.string 'name'
    t.string 'nationality'
    t.string 'email'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['nationality'], name: 'index_customers_on_nationality'
  end

  create_table 'odometer_readings', force: :cascade do |t|
    t.bigint 'vehicle_id', null: false
    t.integer 'value', null: false
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['vehicle_id'], name: 'index_odometer_readings_on_vehicle_id'
  end

  create_table 'vehicles', force: :cascade do |t|
    t.bigint 'customer_id', null: false
    t.string 'model', null: false
    t.integer 'year', null: false
    t.bigint 'chassis_number', null: false
    t.string 'color'
    t.date 'registration_date'
    t.uuid 'batch_id'
    t.datetime 'created_at', precision: 6, null: false
    t.datetime 'updated_at', precision: 6, null: false
    t.index ['chassis_number'], name: 'index_vehicles_on_chassis_number', unique: true
    t.index ['customer_id'], name: 'index_vehicles_on_customer_id'
    t.index ['model'], name: 'index_vehicles_on_model'
  end

  add_foreign_key 'odometer_readings', 'vehicles', on_delete: :cascade
  add_foreign_key 'vehicles', 'customers', on_delete: :cascade
end
