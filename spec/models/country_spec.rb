require 'rails_helper'
describe Study do
  it "study should have expected country info" do
    nct_id='NCT02586688'
    xml=Nokogiri::XML(File.read("spec/support/xml_data/#{nct_id}.xml"))
    study=Study.new({xml: xml, nct_id: nct_id}).create
    expect(study.countries.size).to eq(2)
    current=study.countries.select{|x|x.removed.nil?}.first
    removed=study.countries.select{|x|!x.removed.nil?}.first
    expect(current.name).to eq('United States')
    expect(removed.name).to eq('Canada')
  end
end

