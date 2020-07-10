module SmartAnswer::Calculators
  class ChildBenefitTaxConfiguration

    def children
      data.fetch(:child).with_indifferent_access
    end

    def questions
      children.each_with_object(HashWithIndifferentAccess.new) do |(key, value), child_and_questions|
        child_and_questions[key] = value.fetch(:question)
      end
    end

  private

    def data
      @data ||= YAML.load_file(Rails.root.join("config/smart_answers/child_benefit_data.yml")).with_indifferent_access
    end
  end
end
