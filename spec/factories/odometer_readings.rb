# frozen_string_literal: true

# == Schema Information
#
# Table name: odometer_readings
#
#  id         :bigint           not null, primary key
#  value      :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  vehicle_id :bigint           not null
#
# Indexes
#
#  index_odometer_readings_on_vehicle_id  (vehicle_id)
#
# Foreign Keys
#
#  fk_rails_...  (vehicle_id => vehicles.id) ON DELETE => cascade
#
FactoryBot.define do
  factory :odometer_reading do
    value { rand(10**6) }
    vehicle
  end
end
