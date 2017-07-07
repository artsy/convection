$ ->
  # Artist autocomplete
  updateArtistSelectionsForm = (selection) ->
    $( "#artist_selections_form #submission_artist_id" ).val( selection.id )
    $( "#artist_selections_form #artist_search" ).val( selection.name )

  if $('#artist_selections_form').length != 0
    $('#artist_selections_form #artist_search').autocomplete(
      source: (request, response) ->
        $.getJSON('/match_artist', term: request.term, response)
      focus: (event, ui) ->
        updateArtistSelectionsForm(ui.item)
        false
      select: (event, ui) ->
        updateArtistSelectionsForm(ui.item)
        false
    )

  # User autocomplete
  updateUserSelectionsForm = (selection) ->
    $( "#user_selections_form #submission_user_id" ).val( selection.id )
    $( "#user_selections_form #user_search" ).val( selection.name )

  if $('#user_selections_form').length != 0
    $('#user_selections_form #user_search').autocomplete(
      source: (request, response) ->
        $.getJSON('/match_user', term: request.term, response)
      focus: (event, ui) ->
        updateUserSelectionsForm(ui.item)
        false
      select: (event, ui) ->
        updateUserSelectionsForm(ui.item)
        false
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      $( "<li class='ui-menu-item'>" )
        .attr( "data-value", item.value )
        .append( "<a class='ui-corner-all'>#{item.name} (#{item.id})</a>" )
        .appendTo( ul )
