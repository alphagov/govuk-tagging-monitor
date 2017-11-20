class GlobalStats
  include StatsHelpers

  GOVUK_ROOT_CONTENT_ID = "f3bbdec2-0e62-4520-a7fd-6ffd5d36e03a".freeze

  BLACKLIST_DOCUMENT_TYPES = %w[
    redirect
    staff_update
    coming_soon
    travel_advice
    html_publication
    manual_section
    hmrc_manual_section
    contact
    completed_transaction
    service_standard_report
    employment_tribunal_decision
    tax_tribunal_decision
    utaac_decision
    dfid_research_output
    asylum_support_decision
    employment_appeal_tribunal_decision
    cma_case
    need
    working_group
    organisation
    person
    worldwide_organisation
    world_location
    topical_event
    policy_area
    field_of_operation
    ministerial_role
    topical_event_about_page
    finder_email_signup
    mainstream_browse_page
    topic
    homepage
    licence_finder
    search
    taxon
    travel_advice_index
    business_support_finder
    finder
    about
    about_our_services
    personal_information_charter
    equality_and_diversity
    our_governance
    services_and_information
    our_energy_use
    corporate_report
    social_media_use
    access_and_opening
    membership
    publication_scheme
    media_enquiries
    complaints_procedure
    help_page
    service_manual_homepage
    service_manual_service_toolkit
    service_manual_service_standard
    service_manual_guide
    service_manual_topic
    gone
  ].freeze

  def run
    total_items = Services.rummager.search(
      count: 0,
      debug: 'include_withdrawn'
    ).to_h.fetch("total")

    taggable_items = Services.rummager.search(
      count: 0,
      reject_content_store_document_type: BLACKLIST_DOCUMENT_TYPES,
      debug: 'include_withdrawn'
    ).to_h.fetch("total")

    root_taxons = Services.publishing_api.get_links(GOVUK_ROOT_CONTENT_ID)
                    .to_h.dig("links", "root_taxons")

    tagged_items = Services.rummager.search(
      count: 0,
      filter_part_of_taxonomy_tree: root_taxons,
      reject_content_store_document_type: BLACKLIST_DOCUMENT_TYPES,
      debug: 'include_withdrawn'
    ).to_h.fetch("total")

    gauge "items", total_items
    gauge "taggable_items", taggable_items
    gauge "taggable_items_with_taxons", tagged_items
    gauge "taggable_items_without_taxons", taggable_items - tagged_items
  end
end
