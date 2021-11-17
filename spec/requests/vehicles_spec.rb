# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Vehicles', type: :request do
  describe 'GET index' do
    it 'renders `index` template, composed of search, import and export template' do
      get '/'
      expect(response).to render_template('index')
      expect(response).to render_template('vehicles/_search_form')
      expect(response).to render_template('vehicles/_import_form')
      expect(response).to render_template('vehicles/_export_form')
    end
  end

  describe 'GET search' do
    it 'returns records with search_term matching  customer name or vehicle model name' do
      setup_records
      get '/vehicles/search',
          params: { 'search_term': 'J' }

      expect(response.status).to be 200
      expect(response).to render_template('vehicles/_vehicle')
      expect(response.body).to include('Jane Thomas') # customer_name
      expect(response.body).to include('INFINITI JX35') # vehicle_model
    end

    it 'returns no record found msg if search_term doesnot match any record' do
      setup_records
      get '/vehicles/search',
          params: { 'search_term': 'random text' }

      expect(response.status).to be 200
      expect(response).not_to render_template('vehicles/_vehicle')
      expect(response.body).to include('No records found!')
    end
  end

  describe 'POST import' do
    it 'returns file not found error if no csv file is supplied' do
      post '/vehicles/import',
           params: { vehicle: nil }

      expect(response.status).to be 200
      expect(response).not_to render_template('vehicles/_vehicle')
      expect(response.body).to include('File not found')
    end

    it 'returns malformed csv error if parsing fails' do
      post '/vehicles/import',
           params: { vehicle: fixture_file_upload('malformed.csv') }

      expect(response.status).to be 200
      expect(response).not_to render_template('vehicles/_vehicle')
      expect(response.body).to include('Error parsing malformed csv file')
    end

    it 'returns zero records imported msg if empty csv is supplied' do
      post '/vehicles/import',
           params: { vehicle: fixture_file_upload('empty.csv') }

      expect(response.status).to be 200
      expect(response).not_to render_template('vehicles/_vehicle')
      expect(response.body).to include('CSV contained zero records')
    end

    it 'returns imported records details on successful file import' do
      post '/vehicles/import',
           params: { vehicle: fixture_file_upload('golden_import.csv') }

      allow_any_instance_of(VehicleImportService).to receive(:import).and_call_original
      expect(response.status).to be 200
      expect(response).to render_template('vehicles/_vehicle')
      expect(Vehicle.count).to be 7
    end

    it 'reports count of records that were imported as well as those failed' do
      setup_records
      post '/vehicles/import',
           params: { vehicle: fixture_file_upload('golden_import.csv') }

      allow_any_instance_of(VehicleImportService).to receive(:import).and_call_original
      expect(response.status).to be 200
      expect(response).not_to render_template('vehicles/_vehicle')
      expect(response.body).to include('Imported =&gt; 0 record(s), Failed =&gt; 7 record(s)')
    end
  end

  describe 'GET export' do
    context 'report_type is supplied as `Customers by nationality`' do
      it 'returns report with customer count by nationality' do
        setup_records
        get '/vehicles/export',
            params: { 'report_type': 'Customers by nationality' }

        allow_any_instance_of(VehicleReportService).to receive(:generate).
                                                         with('Customers by nationality').and_call_original

        expect(response.status).to be 200
        expect(response.headers['Content-Type']).to eq 'text/csv; charset=utf-8'
        expect(response.headers['Content-Disposition'].strip).to eq 'attachment; filename=customers_by_nationality.csv'
      end
    end

    context 'report_type is supplied as `Average readings by nationality`' do
      it 'returns report with customer count by nationality' do
        setup_records
        get '/vehicles/export',
            params: { 'report_type': 'Average readings by nationality' }

        allow_any_instance_of(VehicleReportService).to receive(:generate).
                                                         with('Average readings by nationality').and_call_original

        expect(response.status).to be 200
        expect(response.headers['Content-Type']).to eq 'text/csv; charset=utf-8'
        expect(response.headers['Content-Disposition']).to eq 'attachment; filename=average_readings_by_nationality.csv '
      end
    end
  end

  private

  def setup_records
    VehicleImportService.new(file_fixture('golden_import.csv')).import
  end
end
