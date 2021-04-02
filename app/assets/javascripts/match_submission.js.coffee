$ ->
  # Autocomplete for submissions index view
  if $('#submission-search-form').length != 0
    $('#submission-search-form').autocomplete(
      source: (request, response) ->
        compiledData = []
        currentStateFilter = $('#state :selected').val()
        baseURL = "/admin/submissions?state=#{currentStateFilter}"
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
        $.getJSON '/admin/users', { term: request.term, size: 5, format: 'json' }, (data) ->
          for item in data
            item.display = item.email
            item.label = 'User'
            item.value = item.id
            item.href = "#{baseURL}&user=#{item.id}"
          compiledData = compiledData.concat data
          respond()
        $.getJSON '/match_artist', { term: request.term, size: 5, format: 'json' }, (data) ->
          for item in data
            item.display = item.name
            item.label = 'Artist'
            item.value = item.id
            item.href = "#{baseURL}&artist=#{item.id}"
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
