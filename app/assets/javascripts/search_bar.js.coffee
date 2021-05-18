$ ->
# Autocomplete for submissions index view
  if $('#search-bar').length != 0
    $('#search-bar').autocomplete(
      source: (request, response) ->
        compiledData = []
        respond = _.after 2, ->
          response compiledData
        $.getJSON '/admin/submissions', { term: request.term, size: 5, format: 'json' }, (data) ->
          for item in data
            item.display = "##{item.id} (#{item.title})"
            item.label = 'Submission'
            item.value = item.id
            item.href = "/admin/submissions/#{item.id}"
          compiledData = compiledData.concat data
          respond()
        $.getJSON '/admin/offers', { term: request.term, size: 10, format: 'json' }, (data) ->
          for item in data
            item.display = "##{item.reference_id}"
            item.label = 'Offer'
            item.value = item.id
            item.href = "/admin/offers/#{item.id}"
          compiledData = compiledData.concat data
          respond()
        $.getJSON '/admin/consignments', { term: request.term, size: 5, format: 'json' }, (data) ->
          for item in data
            item.display = "##{item.reference_id}"
            item.label = 'Consignment'
            item.value = item.id
            item.href = "/admin/consignments/#{item.id}"
          compiledData = compiledData.concat data
          respond()
      select: (e) ->
        false
    ).data("ui-autocomplete")._renderMenu = (ul, items) ->
      groupedItems = _.groupBy items, (item) -> item.label
      for label, items of groupedItems
        $("""
          <li class='section-label'>#{label}</li>
          """).data("item.autocomplete", items[0]).appendTo(ul)
        for item in items
          $("""
            <li>
              <a href=#{item.href} id='#{item.label.toLowerCase()}-#{item.id}'>
                <span class='left'>&nbsp;</span>
                <span class='display'>#{item.display}</span>
              </a>
            </li>
            """).data("item.autocomplete", item).appendTo(ul)
