# frozen_string_literal: true

# == Schema Information
#
# Table name: customers
#
#  id          :bigint           not null, primary key
#  email       :string
#  name        :string
#  nationality :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_customers_on_nationality  (nationality)
#
require 'rails_helper'

describe Customer, type: :model do
  it 'can have vehicle with odometer readings' do
    customer = create :customer_with_vehicles, readings_count: 3
    expect(customer.vehicles.count).to be(1)
    expect(customer.vehicles.first.odometer_readings.count).to be(3)
  end
end
