class ParticipantFlow < StudyRelationship
  has_many :milestones, inverse_of: :participant_flow, autosave: true
  has_many :drop_withdrawals, inverse_of: :participant_flow, autosave: true

  # WIP
  # has_many :result_groups, inverse_of: :participant_flow, autosave: true

  def self.top_level_label
    '//participant_flow'
  end

  def self.create_all_from(opts)
    objects=xml_entries(opts).collect{|xml|
      opts[:xml]=xml
      participant_flow = new.create_from(opts)

      milestones = Milestone.create_all_from(opts)
      drop_withdrawals = DropWithdrawal.create_all_from(opts)
      result_groups = ResultGroup.create_all_from(opts)

      milestones.each do |milestone|
        participant_flow.milestones.build(milestone.attributes)
      end

      drop_withdrawals.each do |drop_withdrawal|
        participant_flow.drop_withdrawals.build(drop_withdrawal.attributes)
      end

      result_groups.each do |result_group|
        participant_flow.result_groups.build(result_group.attributes)
      end

      participant_flow
    }.compact


    ParticipantFlow.import(objects, recursive: true)
  end

  def attribs
    {
      recruitment_details: xml.xpath("//participant_flow").xpath('recruitment_details').try(:text),
      pre_assignment_details: xml.xpath("//participant_flow").xpath('pre_assignment_details').try(:text),
      group_title: xml.xpath("//participant_flow").xpath('group_list').xpath('group').xpath('title').try(:text),
      group_description: xml.xpath("//participant_flow").xpath('group_list').xpath('group').xpath('description').try(:text)
    }
  end

end
