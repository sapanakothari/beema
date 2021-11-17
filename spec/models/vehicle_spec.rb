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
require 'rails_helper'

describe Vehicle, type: :model do
  it 'requires chassis_number, model and year to be specified' do
    vehicle = Vehicle.new

    expect(vehicle).not_to be_valid
    expect(vehicle.errors[:model]).to include("can't be blank")
    expect(vehicle.errors[:chassis_number]).to include('is not a number')
    expect(vehicle.errors[:year]).to include('is not a number')
  end

  it 'requires registration date to not be in future' do
    vehicle = build :vehicle, registration_date: Date.tomorrow

    expect(vehicle).not_to be_valid
    expect(vehicle.errors[:registration_date]).to include("must be less than #{Date.tomorrow}")
  end

  it 'requires year to be within 1900 and current year' do
    year_and_expected_errors = {
      1899 => ['must be greater than or equal to 1900'],
      1900 => [],
      Date.current.year => [],
      Date.current.year + 1 => ["must be less than or equal to #{Date.current.year}"],
    }

    year_and_expected_errors.each do |year, errors|
      vehicle = build :vehicle, year: year
      vehicle.valid?
      expect(vehicle.errors[:year]).to be_eql(errors)
    end
  end

  it 'can have several odometer readings' do
    vehicle = create :vehicle
    create :odometer_reading, vehicle: vehicle
    create :odometer_reading, vehicle: vehicle

    expect(vehicle.odometer_readings.count).to be(2)
  end
end
