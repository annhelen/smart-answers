module SmartAnswer
  class HelpIfYouAreArrestedAbroadFlow < Flow
    def define
      start_page_content_id "cb62c931-a0fa-4363-b33d-12ac06d6232a"
      flow_content_id "d5074786-f3cc-410e-bc3d-d52008f0a692"
      name "help-if-you-are-arrested-abroad"
      status :published
      satisfies_need "100220"

      arrested_calc = Calculators::ArrestedAbroad.new
      exclude_countries = %w[holy-see british-antarctic-territory]
      british_overseas_territories = %w[anguilla bermuda british-indian-ocean-territory british-virgin-islands cayman-islands falkland-islands gibraltar montserrat pitcairn-island st-helena-ascension-and-tristan-da-cunha south-georgia-and-the-south-sandwich-islands turks-and-caicos-islands]

      # Q1
      country_select :which_country?, exclude_countries: exclude_countries do
        save_input_as :country

        calculate :location do
          loc = WorldLocation.find(country)
          raise InvalidResponse unless loc

          loc
        end

        calculate :organisation do
          location.fco_organisation
        end

        calculate :country_name do
          location.name
        end

        calculate :pdf do
          arrested_calc.generate_url_for_download(country, "pdf", "Prisoner pack for #{country_name}")
        end

        calculate :doc do
          arrested_calc.generate_url_for_download(country, "doc", "Prisoner pack for #{country_name}")
        end

        calculate :benefits do
          arrested_calc.generate_url_for_download(country, "benefits", "Benefits or legal aid in #{country_name}")
        end

        calculate :prison do
          arrested_calc.generate_url_for_download(country, "prison", "Information on prisons and prison procedures in #{country_name}")
        end

        calculate :judicial do
          arrested_calc.generate_url_for_download(country, "judicial", "Information on the judicial system and procedures in #{country_name}")
        end

        calculate :police do
          arrested_calc.generate_url_for_download(country, "police", "Information on the police and police procedures in #{country_name}")
        end

        calculate :consul do
          arrested_calc.generate_url_for_download(country, "consul", "Consul help available in #{country_name}")
        end

        calculate :lawyer do
          arrested_calc.generate_url_for_download(country, "lawyer", "English speaking lawyers and translators/interpreters in #{country_name}")
        end

        calculate :has_extra_downloads do
          [police, judicial, consul, prison, lawyer, benefits, doc, pdf].count { |x|
            x != ""
          }.positive? || arrested_calc.countries_with_regions.include?(country)
        end

        calculate :region_links do
          links = []
          if arrested_calc.countries_with_regions.include?(country)
            regions = arrested_calc.get_country_regions(country)
            regions.each_value do |val|
              links << "- [#{val['url_text']}](#{val['link']})"
            end
          end
          links
        end

        next_node do |response|
          if response == "syria"
            outcome :answer_three_syria
          elsif british_overseas_territories.include?(response)
            outcome :answer_three_british_overseas_territories
          else
            outcome :answer_one_generic
          end
        end
      end

      outcome :answer_one_generic do
        precalculate :iran do
          country_name == "Iran"
        end

        precalculate :transfers_back_to_uk_treaty_change_countries do
          %w[austria belgium croatia denmark finland hungary italy latvia luxembourg malta netherlands slovakia]
        end

        precalculate :region_downloads do
          region_links.join("\n")
        end
      end

      outcome :answer_three_syria

      outcome :answer_three_british_overseas_territories
    end
  end
end
