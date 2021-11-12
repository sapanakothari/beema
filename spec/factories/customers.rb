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
FactoryBot.define do
  factory :customer do
    email { 'random@gmail.com' }
    name { 'Jane Thomas' }
    nationality { 'Australia' }

    factory :customer_with_vehicles do
      transient do
        readings_count { 2 }
      end
      vehicles { [association(:vehicle, :with_odometer_readings, readings_count: readings_count)] }
    end
  end
end
