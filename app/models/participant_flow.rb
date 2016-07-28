class ParticipantFlow < StudyRelationship

  def attribs
    {
      recruitment_details: xml.xpath("//participant_flow").xpath('recruitment_details').try(:text),
      pre_assignment_details: xml.xpath("//participant_flow").xpath('pre_assignment_details').try(:text),
      group_title: xml.xpath("//participant_flow").xpath('group_list').xpath('group').xpath('title').try(:text),
      group_description: xml.xpath("//participant_flow").xpath('group_list').xpath('group').xpath('description').try(:text)
    }
  end

end
