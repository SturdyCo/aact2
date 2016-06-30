module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url, :processed_studies
    def initialize(search_term: nil)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
      @processed_studies = {
        updated_studies: [],
        new_studies: []
      }
    end

    def download_xml_files
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'get_studies'
      )

      file = Tempfile.new('xml')

      download = RestClient::Request.execute({
        url:          @url,
        method:       :get,
        content_type: 'application/zip'
      })

      file.binmode
      file.write(download)
      file.size

      zipfiles = Zip::File.open(file.path)
      zipfiles.each do |file|
        study_xml = file.get_input_stream.read
        create_study_xml_record(study_xml)
      end

      load_event.complete
    end

    def create_study_xml_record(xml)
      nct_id = extract_nct_id_from_study(xml)
      new_study_xml = Nokogiri::XML(xml)
      existing_study_xml_record = StudyXmlRecord.find_by(nct_id: nct_id)
      existing_study_xml = Nokogiri::XML(existing_study_xml_record.try(:content))

      if existing_study_xml_record.blank?
        @processed_studies[:new_studies] << nct_id
        StudyXmlRecord.create(content: xml, nct_id: nct_id)
        # report number of new records
      elsif study_xml_changed?(existing_study_xml: existing_study_xml, new_study_xml: new_study_xml)
        @processed_studies[:updated_studies] << nct_id
        existing_study_xml_record.update(content: xml)
        # report number of changed records
      end
    end

    def populate_studies
      load_event = ClinicalTrials::LoadEvent.create(
        event_type: 'populate_studies'
      )

      StudyXmlRecord.find_each do |xml_record|
        raw_xml = xml_record.content
        import_xml_file(raw_xml)
      end

      load_event.complete
    end

    def import_xml_file(study_xml, benchmark: false)
      if benchmark
        load_event = ClinicalTrials::LoadEvent.create(
          event_type: 'get_studies'
        )
      end

      study = Nokogiri::XML(study_xml)
      nct_id = extract_nct_id_from_study(study_xml)

      existing_study = Study.find_by(nct_id: nct_id)

      if !existing_study
        study_record = Study.new({
          xml: study,
          nct_id: nct_id
        })

        study_record.create
        # report number of new records
      elsif study_changed?(existing_study: existing_study, new_study_xml: study)
        return if study.blank?
        existing_study.xml = study
        existing_study.update(existing_study.attribs)
        existing_study.study_xml_record.update(content: study)
        # report number of changed records
      end

      if benchmark
        load_event.complete
      end
    end

    private

    def extract_nct_id_from_study(study)
      Nokogiri::XML(study).xpath('//nct_id').text
    end

    def study_xml_changed?(existing_study_xml:, new_study_xml:)
      existing_study_xml.diff(new_study_xml) do |change,node|
        return true if change.present? && node.parent.name != 'download_date'
      end
      false
    end

    def study_changed?(existing_study:, new_study_xml:)
      date_string = new_study_xml.xpath('//clinical_study')
      .xpath('lastchanged_date').text

      date = Date.parse(date_string)

      date != existing_study.last_changed_date
    end
  end
end
