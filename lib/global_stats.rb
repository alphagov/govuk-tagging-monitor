class GlobalStats
  include StatsHelpers

  def run
    total_items = HTTP.get_json("https://www.gov.uk/api/search.json?count=0&debug=include_withdrawn")
    gauge "items", total_items.fetch("total")

    untagged_items = HTTP.get_json("https://www.gov.uk/api/search.json?count=0&filter_taxons=_MISSING&debug=include_withdrawn")
    gauge "items_without_taxons", untagged_items.fetch("total")

    gauge "items_with_taxons", total_items.fetch("total") - untagged_items.fetch("total")
  end
end
