require 'zip'
require 'tempfile'
require 'open3'

module ClinicalTrials
  class Client
    BASE_URL = 'https://clinicaltrials.gov'

    attr_reader :url

    def initialize(search_term: nil)
      @url = "#{BASE_URL}/search?term=#{search_term.try(:split).try(:join, '+')}&resultsxml=true"
    end

    def get_studies
      # mem = MemoryUsageMonitor.new
      # mem.start

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

      # system("unzip #{file.path} -d #{Rails.root}/tmp/xml")
      #
      # IO.popen("unzip -c #{file.path}", 'rb') do |io|
      #   # get each xml study
      #   # create study record
      #   binding.pry
      # end

      Zip::File.open(file.path) do |zipfile|
        zipfile.each do |file|
          study = file.get_input_stream.read
          nct_id = extract_nct_id_from_study(study)

          import_xml_file(study)
        end

      end

      load_event.complete

      # mem.stop
      # puts "Peak memory: #{mem.peak_memory/1024} MB"
    end

    def import_xml_file(study_xml)
      study = Nokogiri::XML(study_xml)
      nct_id = extract_nct_id_from_study(study_xml)

      existing_study = Study.find_by(nct_id: nct_id)

      if new_study?(study_xml)
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
        # report number of changed records
      end
    end

    # def populate_studies(path:)
    #   mem = MemoryUsageMonitor.new
    #   mem.start

    #   load_event = ClinicalTrials::LoadEvent.create(
    #     event_type: 'populate_studies'
    #   )
    #   new = 0
    #   changed = 0

    #   study_records = []
    #   Dir.foreach(path) do |study|
    #     next if study == '.' or study == '..'
    #     study = File.read("#{path}/#{study}")

    #     nct_id = extract_nct_id_from_study(study)

    #     study_record = Study.new({
    #       xml: Nokogiri::XML(study),
    #       nct_id: nct_id
    #     })

    #     if new_study?(study)
    #       new += 1
    #       study_records << study_record
    #     elsif study_changed?(existing_study: study_record,
    #                          new_study_xml: study)
    #       changed += 1
    #     end
    #   end

    #   Study.bulk_insert do |worker|
    #     study_records.compact.each do |record|
    #       worker.add(record.attribs.merge(nct_id: record.nct_id))
    #     end
    #   end

    #   load_event.complete
    #   load_event.generate_report(new: new, changed: changed)

    #   mem.stop
    #   puts "Peak memory: #{mem.peak_memory/1024} MB"
    # end

    private

    def extract_nct_id_from_study(study)
      Nokogiri::XML(study).xpath('//nct_id').text
    end

    def new_study?(study)
      found = Study.find_by(nct_id: extract_nct_id_from_study(study))

      if found
        false
      else
        true
      end
    end

    def study_changed?(existing_study:, new_study_xml:)
      date_string = new_study_xml.xpath('//clinical_study')
                                 .xpath('lastchanged_date').inner_html

      date = Date.parse(date_string)

      date != existing_study.last_changed_date
    end
  end
end
