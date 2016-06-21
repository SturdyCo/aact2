require 'rails_helper'

describe 'Studies API', type: :request do
  before do
    xml = File.read(Rails.root.join(
      'spec',
      'support',
      'xml_data',
      'example_study.xml'
    ))

    @xml_record = StudyXmlRecord.create(content: xml, nct_id: 'NCT00002475')
    client = ClinicalTrials::Client.new
    client.populate_studies
  end

  let(:study) { Study.last }

  describe '[GET] study by nct_id' do

    context 'success' do
      it 'should return the study' do
        get "/api/studies/#{study.nct_id}"

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body)['study'].to_json).to eq(study.to_json)
      end

      context 'with related records' do

        context 'all one to one relationships' do
          it 'should return all related records for study' do
            get "/api/studies/#{study.nct_id}?with_related_records=true"

            expect(response.status).to eq(200)
            expect(JSON.parse(response.body)['study']['brief_summary'].present?).to eq(true)
            expect(JSON.parse(response.body)['study']['design'].present?).to eq(true)
          end
        end

      end
    end

    context 'failure' do

      context 'study not found' do
        it 'should return 404' do
          get "/api/studies/abc123?with_related_records=true"

          expect(response.status).to eq(404)
        end
      end

    end

  end

  describe '[GET] all studies' do
    before do
      5.times do
        Study.create(xml: '')
      end
    end

    context 'success' do
      it 'should return all studies' do
        get '/api/studies'

        expect(response.status).to eq(200)
        expect(JSON.parse(response.body).length).to eq(6)
      end
    end

    context 'failure'
  end

  describe '[GET] study counts by year' do
    it 'should return a hash of years with counts of studies' do
      get '/api/studies/counts_by_year'

      study_start_year = Study.last.start_date.year.to_s

      expect(JSON.parse(response.body)[study_start_year]).to eq(1)
    end
  end
end