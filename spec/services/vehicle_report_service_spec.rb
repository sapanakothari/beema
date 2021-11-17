# frozen_string_literal: true

require 'rails_helper'

describe VehicleReportService, type: :class do
  before do
    VehicleImportService.new(file_fixture('golden_import.csv')).import
  end

  it 'requires valid report_type file to be supplied' do
    response = VehicleReportService.new(nil).generate

    expect(response.success?).to be(false)
    expect(response.error_code).to be :unknown_report_type
  end

  context 'when report_type is `Customers by nationality`' do
    it 'returns count of customer by nationality ' do
      expected_count = { 'Sasank': 1,
                         'Elabd': 1,
                         'Mohan': 1,
                         'Australia': 1,
                         'Belgium': 1,
                         'Kirke': 2, }

      response = VehicleReportService.new('Customers by nationality').generate
      actual_count = csv_to_hash(response.csv)

      expect(actual_count).to eq(expected_count)
    end
  end

  context 'when report_type is `Average readings by nationality`' do
    it 'returns avearge reading by nationality' do
      expect_avg = { 'Sasank': 34000,
                     'Elabd': 12300,
                     'Mohan': 123000,
                     'Australia': 25000,
                     'Belgium': 34000,
                     'Kirke': (30000 + 12000) / 2, }

      response = VehicleReportService.new('Average readings by nationality').generate
      actual_avg = csv_to_hash(response.csv)

      expect(actual_avg).to eq expect_avg
    end
  end

  private

  def csv_to_hash(csv)
    Hash[csv.split.drop(1).map { |e| e.split(',') }].symbolize_keys.transform_values(&:to_i)
  end
end
