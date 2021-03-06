module SmartAnswer::Calculators
  class BenefitCapCalculatorConfiguration
    attr_accessor :exempted_benefits

    def weekly_benefit_caps(region = :national)
      data.fetch(:weekly_benefit_caps)[region].with_indifferent_access
    end

    def weekly_benefit_cap_descriptions(region = :national)
      weekly_benefit_caps(region).each_with_object(HashWithIndifferentAccess.new) do |(key, value), weekly_benefit_cap_description|
        weekly_benefit_cap_description[key] = value.fetch(:description)
      end
    end

    def weekly_benefit_cap_amount(family_type, region = :national)
      weekly_benefit_caps(region).fetch(family_type)[:amount]
    end

    def benefits
      data.fetch(:benefits).with_indifferent_access
    end

    def exempt_benefits
      data.fetch(:exempt_benefits)
    end

    def exempted_benefits?
      ListValidator.new(exempt_benefits.keys).all_valid?(exempted_benefits)
    end

    def questions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_questions|
        benefits_and_questions[key] = value.fetch(:question)
      end
    end

    def descriptions
      benefits.each_with_object(HashWithIndifferentAccess.new) do |(key, value), benefits_and_descriptions|
        benefits_and_descriptions[key] = value.fetch(:description)
      end
    end

    def region(postcode)
      london?(postcode) ? :london : :national
    end

    def london?(postcode)
      area(postcode).any? do |result|
        result["type"] == "EUR" && result["name"] == "London"
      end
    end

    def area(postcode)
      response = GdsApi.imminence.areas_for_postcode(postcode)&.to_hash
      OpenStruct.new(response).results || []
    end

  private

    def data
      @data ||= YAML.load_file(Rails.root.join("config/smart_answers/benefit_cap_data.yml")).with_indifferent_access
    end
  end
end
