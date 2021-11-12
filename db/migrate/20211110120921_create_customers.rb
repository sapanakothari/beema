# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.0]
  def change
    create_table :customers do |t|
      t.string :name
      t.string :nationality
      t.string :email
      t.timestamps
    end

    add_index :customers, %i[nationality]
  end
end
