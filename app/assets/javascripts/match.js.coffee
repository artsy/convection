$ ->
  # Autocomplete for submissions index view
  if $('#submission-search-form').length != 0
    $('#submission-search-form').autocomplete(
      source: (request, response) ->
        $.getJSON('/match', { term: request.term, match_users: true }, response)
      select: (event, ui) ->
        console.log('selected!!!!!!!!!!!!!')
        false
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      # console.log("UGHHH", item.first)
      $.each item, (it) ->
        return $( "<li class='ui-menu-item'>" )
          .attr( "data-value", it.id )
          .append( "<a class='ui-corner-all'>#{it.email}</a>" )
          .appendTo( ul )

      # $.each item (it) ->
      #   console.log("ITEMMM", it)
      #   $( "<li class='ui-menu-item'>" )
      #     .attr( "data-value", it.value )
      #     .append( "<a class='ui-corner-all'>#{it.email}</a>" )
      #     .appendTo( ul )
