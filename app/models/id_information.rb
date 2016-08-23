class IdInformation < StudyRelationship
  self.table_name = "id_information"
  def self.top_level_label
    '//id_info'
  end

  def self.create_all_from(opts)
    id_informations =  org_study_ids(opts) + secondary_ids(opts) + aliases(opts)
    IdInformation.import(id_informations)
  end

  def self.org_study_ids(opts)
    opts[:xml].xpath("//org_study_id").collect{|xml|
      IdInformation.new.create_from({:xml=>xml, :id_type=>'org_study_id', :id_value=>xml.text.strip, :nct_id=>(opts[:nct_id]) }) }

  end

  def self.secondary_ids(opts)
    opts[:xml].xpath("//secondary_id").collect{|xml|
      IdInformation.new.create_from({:xml=>xml, :id_type=>'secondary_id', :id_value=>xml.text.strip, :nct_id=>(opts[:nct_id]) }) }
  end

  def self.aliases(opts)
    opts[:xml].xpath("//nct_alias").collect{|xml|
      IdInformation.new.create_from({:xml=>xml, :id_type=>'nct_alias', :id_value=>xml.text.strip, :nct_id=>(opts[:nct_id]) }) }
  end

  def create_from(opts={})
    @opts = opts
    @xml = opts[:xml] || opts
    self.nct_id = opts[:nct_id]
    self.id_type = opts[:id_type]
    self.id_value = opts[:id_value]
    self
  end
end
