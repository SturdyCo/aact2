class Country < StudyRelationship

  def self.create_all_from(opts)
		countries = current(opts) + removed(opts)
    Country.import(countries)
  end

  def self.current(opts)
    opts[:xml].xpath("//location_countries").collect{|xml|
      Country.new({:name=>xml.text.strip,:nct_id=>opts[:nct_id]})
    }
  end

  def self.removed(opts)
    opts[:xml].xpath("//removed_countries").collect{|xml|
      Country.new({:name=>xml.text.strip,:nct_id=>opts[:nct_id],:removed=>true})
    }
  end

end
