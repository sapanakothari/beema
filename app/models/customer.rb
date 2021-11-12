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
class Customer < ApplicationRecord
  has_many :vehicles, inverse_of: :customer
end
