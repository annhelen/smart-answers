require_relative "../../test_helper"
require_relative "flow_test_helper"

require "smart_answer_flows/child-benefit-tax-calculator"

class ChildBenefitTaxCalculatorTest < ActiveSupport::TestCase
  include FlowTestHelper

  setup do
    setup_for_testing_flow SmartAnswer::ChildBenefitTaxCalculatorFlow
  end

  # Q1 How many children?
  # Q2 Which tax year?
  # Q3 Claiming for part tax year?
  # Q3a How many part year children?
  # Q3b Child part time start date(s)
  # Q3c Child part time stop date(s) (optional)
  # Q4 Income details
  # Q5a Additional income_details (pension_contributions_from_pay, gift_aid_donations, outgoing_pension_contributions)
  # Q5b Additional income_details (retirement_annuities, cycle_scheme) (optional)

  context "Child Benefit tax calculator" do
    context "When claiming for one child" do
      # Q1 How many children?
      should "ask how_many_children? question" do
        assert_current_node :how_many_children?
      end

      context "answer how_many_children? with 1" do
        setup { add_response "1" }

        # Q2 Which tax year?s
        should "ask which_tax_year? question" do
          assert_current_node :which_tax_year?
        end

        context "answer which_tax_year? with 2012" do
          setup { add_response "2012" }

          # Q3 Claiming for part tax year?
          should "ask is_part_year_claim? question" do
            assert_current_node :is_part_year_claim?
          end

          context "answer is_part_year_claim? with yes" do
            setup { add_response "yes" }

            # Q3a How many part year children?
            should "ask how_many_children_part_year? question" do
              assert_current_node :how_many_children_part_year?
            end

            context "answer how_many_children_part_year? with 1" do
              setup { add_response "1" }

              # Q3b Child part time start date
              should "ask starting_children_0? question" do
                assert_current_node :starting_children_0?
              end

              context "answer starting_children_0? with 1/6/2012" do
                setup { add_response "2012-06-01" }

                # Q3b Child part time stop date
                should "ask stopping_children_0? question" do
                  assert_current_node :stopping_children_0?
                end
              end

              context "answer stopping_children_0? with 1/6/2013" do
                setup { add_response "2013-06-01" }

                should "ask income_details? question" do
                  assert_current_node :income_details?
                end

                context "answer income_details? with 30000" do
                  setup { add_response "30000" }

                  should "ask allowable_deductions? question" do
                    assert_current_node :allowable_deductions?
                  end

                  context "answer allowable_deductions? with 1000" do
                    setup { add_response "1000" }

                    should "ask other_allowable_deductions? question" do
                      assert_current_node :other_allowable_deductions?
                    end

                    context "answer other_allowable_deductions? with 800" do
                      setup { add_response "800" }

                      should "go to outcome X" do
                        assert_current_node :outcome_to_be_added
                      end
                    end
                  end
                end
              end
            end
          end

          context "answer is_part_year_claim? with no" do
            setup { add_response "no" }

            should "ask income_details? question" do
              assert_current_node :income_details?
            end

            context "answer income_details? with 30000" do
              setup { add_response "30000" }

              should "ask allowable_deductions? question" do
                assert_current_node :allowable_deductions?
              end

              context "answer allowable_deductions? with 1000" do
                setup { add_response "1000" }

                should "ask other_allowable_deductions? question" do
                  assert_current_node :other_allowable_deductions?
                end

                context "answer other_allowable_deductions? with 800" do
                  setup { add_response "800" }

                  should "go to outcome X" do
                    assert_current_node :outcome_to_be_added
                  end
                end
              end
            end
          end
        end
      end
    end



  context "when claiming for more than one child"
  end
end
