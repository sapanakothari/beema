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
class Vehicle < ApplicationRecord
  belongs_to :customer, inverse_of: :vehicles
  has_many :odometer_readings, -> { order created_at: :desc }, inverse_of: :vehicle
  has_one :latest_reading, -> { order created_at: :desc }, class_name: 'OdometerReading'

  validates :chassis_number, presence: true, numericality: { only_integer: true }

  validates :year,
            presence: true,
            numericality: { greater_than_or_equal_to: 1900, less_than_or_equal_to: ->(_year) { Date.current.year } }

  validates_comparison_of :registration_date, less_than: ->(_reg_date) { Date.tomorrow }, allow_blank: true

  validates :model, presence: true
end
