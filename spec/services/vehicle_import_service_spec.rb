# frozen_string_literal: true

require 'rails_helper'

describe VehicleImportService, type: :class do
  it 'requires valid csv file to be supplied' do
    response = VehicleImportService.new(nil).import

    expect(response.success?).to be(false)
    expect(response.error_code).to be :file_not_found
  end

  it 'returns :file_parse_error if the supplied csv is malformed' do
    file_path = Rails.root.join('spec/fixtures/malformed.csv')
    response = VehicleImportService.new(file_path).import

    expect(response.success?).to be false
    expect(response.error_code).to be :file_parse_error
  end

  it 'imports records from csv if the data is ok' do
    file_path = Rails.root.join('spec/fixtures/golden_import.csv')
    response = VehicleImportService.new(file_path).import

    expect(response.success?).to be true
    expect(response.error_code).to be_nil
    expect(response.errors).to be_empty

    expect(response.import_summary[:total_csv_record]).to be 7
    expect(response.import_summary[:imported_count]).to be 7
    expect(response.import_summary[:failed_count]).to be 0
  end

  it 'sets same batch_id to all Vehicle records imported from same csv' do
    file_path = Rails.root.join('spec/fixtures/golden_import.csv')
    response = VehicleImportService.new(file_path).import

    expect(response.success?).to be true
    expect(Vehicle.pluck(:batch_id).uniq).to eq [response.import_summary[:batch_id]]
  end

  it 'strips leading and trailing whitespaces from records before persisting' do
    file_path = Rails.root.join('spec/fixtures/with_whitespace_import.csv')
    response = VehicleImportService.new(file_path).import

    expect(response.success?).to be true
    expect(Customer.first.name).to eq 'Gemma'
    expect(Customer.first.nationality).to eq 'Kirke'
  end

  it 'reports row_id & error for records that failed import for violating unique constraints' do
    unique_constraint_error = 'PG::UniqueViolation: ERROR:  duplicate key value violates unique constraint'
    file_path = Rails.root.join('spec/fixtures/golden_import.csv')
    _import = VehicleImportService.new(file_path).import
    reimport = VehicleImportService.new(file_path).import

    expect(reimport.success?).to be true
    expect(reimport.import_summary[:failed_count]).to eq reimport.import_summary[:total_csv_record]
    expect(reimport.import_summary[:imported_count]).to be_zero

    expect(reimport.import_summary[:failed_vehicles].first[:row_id]).to be 1
    expect(reimport.import_summary[:failed_vehicles].first[:errors]).to include unique_constraint_error
  end
end
