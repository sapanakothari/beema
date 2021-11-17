# frozen_string_literal: true

class VehiclesController < ApplicationController
  def index; end

  def search
    @vehicles = Vehicle.
                  eager_load(:latest_reading, :customer).
                  joins('FULL OUTER JOIN customers ON customers.id = vehicles.customer_id').
                  where('customers.name LIKE ? or vehicles.model LIKE ?', search_term, search_term)
  end

  def import
    @response = VehicleImportService.new(import_file_path).import
    if @response.success?
      batch_id = @response.import_summary[:batch_id]

      @vehicles = Vehicle.
                    includes(:customer, :odometer_readings).
                    where(batch_id: batch_id)
    end
  end

  def export
    @response = VehicleReportService.new(report_type).generate
    if @response.success?
      send_data @response.csv,
                type: 'text/csv; charset=utf-8; header=present',
                disposition: "attachment; filename=#{@response.report_name} "
    end
  end

  private

  def import_file_path
    params[:vehicle].tempfile.path if params[:vehicle].present?
  end

  def search_term
    "%#{params[:search_term]}%"
  end

  def report_type
    params[:report_type]
  end
end
