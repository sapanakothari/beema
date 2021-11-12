# frozen_string_literal: true

# == Schema Information
#
# Table name: vehicles
#
#  id                :bigint           not null, primary key
#  chassis_number    :bigint           not null
#  color             :string
#  model             :string           not null
#  registration_date :date
#  year              :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  batch_id          :uuid
#  customer_id       :bigint           not null
#
# Indexes
#
#  index_vehicles_on_chassis_number  (chassis_number) UNIQUE
#  index_vehicles_on_customer_id     (customer_id)
#  index_vehicles_on_model           (model)
#
# Foreign Keys
#
#  fk_rails_...  (customer_id => customers.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :vehicle do
    model { 'Ford' }
    year { 2018 }
    color { 'Black' }
    chassis_number { rand(10**10) }
    registration_date { 1.year.ago }
    customer

    trait :with_odometer_readings do
      transient do
        readings_count { 2 }
      end

      after(:create) do |vehicle, evaluator|
        create_list(:odometer_reading, evaluator.readings_count, vehicle: vehicle)
        vehicle.reload
      end
    end
  end
end
