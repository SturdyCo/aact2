class CalculatedValue < ActiveRecord::Base
  belongs_to :study, :foreign_key => 'nct_id'

  def create_from(new_study)
    self.study=new_study
    assign_attributes(attribs) if !attribs.blank?
    create_pma_records
    self
  end

  def attribs
    {
      :sponsor_type                => calc_sponsor_type,
      :actual_duration             => calc_actual_duration,
      :enrollment                  => calc_enrollment,
      :results_reported            => calc_results_reported,
      :months_to_report_results    => calc_months_to_report_results,
      :registered_in_calendar_year => calc_registered_in_calendar_year,
      :number_of_facilities        => calc_number_of_facilities,
      :number_of_sae_subjects      => calc_number_of_sae_subjects,
      :number_of_nsae_subjects     => calc_number_of_nsae_subjects,
    }
  end

  def calc_sponsor_type
    val=study.lead_sponsor.try(:agency_class)
    return val if val=='Industry' or val=='NIH'
    study.collaborators.each{|c|return 'NIH' if c.agency_class=='NIH'}
    study.collaborators.each{|c|return 'Industry' if c.agency_class=='Industry'}
    return 'Other'
  end

  def calc_number_of_sae_subjects
    if ReportedEvent.fast_count_estimate(study.reported_events) > 0
      study.reported_events.where('event_type = \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
  end

  def calc_number_of_nsae_subjects
    if ReportedEvent.fast_count_estimate(study.reported_events) > 0
      study.reported_events.where('event_type != \'serious\' and subjects_affected is not null').sum(:subjects_affected)
    end
  end

  def calc_registered_in_calendar_year
    study.first_received_date.year
  end

  def calc_number_of_facilities
    study.facilities.count
  end

  def calc_actual_duration
    return if !study.primary_completion_date or !study.start_date
    (study.primary_completion_date - study.start_date).to_f/365
  end

  def calc_results_reported
    1 if Outcome.fast_count_estimate(study.reported_events) > 0
  end

  def calc_months_to_report_results
    return nil if study.first_received_results_date.nil? or study.primary_completion_date.nil?
    ((study.first_received_results_date.to_time -  study.primary_completion_date.to_time)/1.month.second).to_i
  end

  def calc_enrollment
    # TODO = this is just a stub - find better way to calculate
    study.result_groups.each{|g|g.set_participant_count}
    study.result_groups.sum(:derived_participant_count)
  end

  def pma_mapping_ids
    study.pma_mappings.collect{|p| {:pma_number=>p.pma_number,:supplement_number=>p.supplement_number} }
  end

  def create_pma_records
    return if study.pma_mappings.empty?
    recs=[]
    pma_mapping_ids.each{|id|
      data=""
      rec = PmaRecord.new.create_from(data) if !data.nil?
      study.pma_records << rec if !rec.nil?
    }
    recs
  end

end
