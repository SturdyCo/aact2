class OutcomeAnalysis < StudyRelationship
  belongs_to :outcome, inverse_of: :outcome_analyses, autosave: true
  belongs_to :result_group

  def self.create_all_from(opts)
    all=opts[:xml].xpath("analysis_list").xpath('analysis')
    col=[]
    xml=all.pop
    return col if xml.blank?
    while xml
      opts[:xml]=xml
      opts[:non_inferiority]=xml.xpath('non_inferiority').text
      opts[:non_inferiority_description]=xml.xpath('non_inferiority_desc').text
      opts[:p_value]=xml.xpath('p_value').text
      opts[:param_type]=xml.xpath('param_type').text
      opts[:param_value]=xml.xpath('param_value').text
      opts[:dispersion_type]=xml.xpath('dispersion_type').text
      opts[:dispersion_value]=xml.xpath('dispersion_value').text
      opts[:ci_percent]=xml.xpath('ci_percent').text
      opts[:ci_n_sides]=xml.xpath('ci_n_sides').text
      opts[:ci_lower_limit]=xml.xpath('ci_lower_limit').text
      opts[:ci_upper_limit]=xml.xpath('ci_upper_limit').text
      opts[:ci_upper_limit_na_comment]=xml.xpath('ci_upper_limit_na_comment').text
      opts[:p_value_description]=xml.xpath('p_value_desc').text
      opts[:method]=xml.xpath('method').text
      opts[:group_description]=xml.xpath('groups_desc').text
      opts[:method_description]=xml.xpath('method_desc').text
      opts[:estimate_description]=xml.xpath('estimate_desc').text
      col << pop_create(opts.merge(:name=>'group_id'))
      xml=all.pop
    end
    col.flatten.compact.map(&:attributes)
  end

  def attribs
    {
      :ctgov_group_id => xml.text,
      :ctgov_group_enumerator => integer_in(xml.text),
      :non_inferiority => get_opt(:non_inferiority),
      :non_inferiority_description => get_opt(:non_inferiority_description),
      :p_value => get_opt(:p_value),
      :param_type => get_opt(:param_type),
      :param_value => get_opt(:param_value),
      :dispersion_type => get_opt(:dispersion_type),
      :dispersion_value => get_opt(:dispersion_value),
      :ci_percent => get_opt(:ci_percent),
      :ci_n_sides => get_opt(:ci_n_sides),
      :ci_lower_limit => get_opt(:ci_lower_limit),
      :ci_upper_limit => get_opt(:ci_upper_limit),
      :ci_upper_limit_na_comment => get_opt(:ci_upper_limit_na_comment),
      :p_value_description => get_opt(:p_value_description),
      :method => get_opt(:method),
      :group_description => get_opt(:group_description),
      :method_description => get_opt(:method_description),
      :estimate_description => get_opt(:estimate_description),
      :outcome => get_opt(:outcome),
    }
  end

  def gid
    integer_in(opts[:xml].text)
  end

  def get_group
    opts[:groups].each {|g| return g if g.ctgov_group_enumerator==gid }
  end

  def conditionally_create_from(opts)
    @opts=opts
    return nil if opts[:xml].text != opts[:group_id_of_interest]
    create_from(opts)
  end

end
