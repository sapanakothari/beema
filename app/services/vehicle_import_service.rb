# frozen_string_literal: true

class VehicleImportService
  require 'csv'

  ERROR_FILE_NOT_FOUND_ERROR = I18n.t('import.file_not_found')
  ERROR_FILE_PARSE_ERROR = I18n.t('import.csv_parsing_error')

  attr_reader :errors
  attr_reader :error_code
  attr_reader :file_path
  attr_reader :csv
  attr_reader :col_sep
  attr_reader :encoding
  attr_reader :vehicles
  attr_reader :import_summary
  attr_reader :vehicle_errors
  attr_reader :batch_id

  def initialize(file_path, col_sep: ',', encoding: 'UTF-8')
    @file_path = file_path
    @errors = []
    @error_code = nil
    @col_sep = col_sep
    @encoding = encoding
    @vehicles = []
    @vehicle_errors = []
    @import_summary = nil
    @batch_id = SecureRandom.uuid
  end

  def import
    file_exists?
    parse_csv
    persist_records
    prepare_import_summary

    VehicleImportServiceResponse.new(errors, error_code, import_summary)
  end

  private

  def file_exists?
    return if errors.any?
    return if file_path && File.exist?(file_path)

    @error_code = :file_not_found
    errors.push(ERROR_FILE_NOT_FOUND_ERROR)
  end

  def parse_csv
    return if errors.any?

    begin
      @csv = CSV.read(@file_path, headers: true, col_sep: col_sep, encoding: encoding,
                                  header_converters: :symbol,)
    rescue CSV::MalformedCSVError => _e
      @error_code = :file_parse_error
      errors.push(ERROR_FILE_PARSE_ERROR)
    end
  end

  def persist_records
    return if errors.any?

    # insert_all is not used as performance is not of concern at this point, optimising for data integrity instead
    csv.each.with_index(1) do |row, index|
      vehicle = build_vehicle(row.to_h.transform_values(&:strip))
      begin
        if vehicle.save
          vehicles << vehicle
        else
          vehicle_errors << { row_id: index, errors: vehicle.errors.full_messages }
        end
      rescue ActiveRecord::RecordNotUnique => e
        vehicle_errors << { row_id: index, errors: e.message }
      end
    end
  end

  def prepare_import_summary
    return if errors.any?

    @import_summary = {
      total_csv_record: csv.count,
      batch_id: batch_id,
      imported_count: vehicles.count,
      failed_count: vehicle_errors.count,
      imported_vehicles: vehicles,
      failed_vehicles: vehicle_errors,
    }
  end

  def build_vehicle(row)
    vehicle = Vehicle.new(model: row[:model],
                          year: row[:year],
                          color: row[:color],
                          chassis_number: row[:chassisnumber],
                          registration_date: to_date(row[:registrationdate]),
                          batch_id: batch_id,)
    vehicle.build_customer(name: row[:name],
                           email: row[:email],
                           nationality: row[:nationality],)
    vehicle.odometer_readings.build(value: row[:odometerreading])

    vehicle
  end

  def to_date(date_s)
    return unless date_s.present?

    begin
      date_s.to_date
    rescue StandardError
      nil
    end
  end
end

class VehicleImportServiceResponse
  attr_reader :errors
  attr_reader :error_code
  attr_reader :import_summary

  def initialize(errors, error_code, import_summary)
    @errors = errors
    @error_code = error_code
    @import_summary = import_summary
  end

  def success?
    errors.any? ? false : true
  end
end
