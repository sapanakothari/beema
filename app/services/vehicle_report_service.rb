# frozen_string_literal: true

class VehicleReportService
  require 'csv'

  UNKNOWN_REPORT_TYPE = I18n.t('report.unknown_type')

  META = {
    I18n.t('report.nationality.customer_count') =>
        { method: :customer_count_by_nationality,
          header: %w[nationality customer_count], },
    I18n.t('report.nationality.avg_readings') =>
          { method: :reading_avg_by_nationality,
            header: %w[nationality avg_readings], },
  }.freeze

  attr_reader :errors
  attr_reader :error_code
  attr_reader :report_name
  attr_reader :csv
  attr_reader :col_sep
  attr_reader :report_type

  def self.report_types
    META.keys
  end

  def initialize(report_type, col_sep: ',')
    @errors = []
    @error_code = nil
    @col_sep = col_sep
    @report_type = report_type
  end

  def generate
    valid_report_type?
    set_report_name
    prepare_report

    VehicleReportServiceResponse.new(errors, error_code, csv, report_name)
  end

  private

  def valid_report_type?
    return if errors.any?
    return if META.keys.include? report_type

    @error_code = :unknown_report_type
    errors.push(UNKNOWN_REPORT_TYPE)
  end

  def set_report_name
    return if errors.any?

    @report_name = "#{report_type.parameterize.underscore}.csv"
  end

  def prepare_report
    return if errors.any?

    header = META[report_type][:header]
    data = send META[report_type][:method]

    @csv = CSV.generate(col_sep: col_sep) do |csv|
      csv << header
      data.each do |row|
        csv << row.to_a
      end
    end
  end

  def customer_count_by_nationality
    Customer.group(:nationality).count
  end

  def reading_avg_by_nationality
    Vehicle.joins(:customer, :latest_reading).group(:nationality).average(:value)
  end
end

class VehicleReportServiceResponse
  attr_reader :errors
  attr_reader :error_code
  attr_reader :csv
  attr_reader :report_name

  def initialize(errors, error_code, csv, report_name)
    @errors = errors
    @error_code = error_code
    @csv = csv
    @report_name = report_name
  end

  def success?
    errors.any? ? false : true
  end
end
