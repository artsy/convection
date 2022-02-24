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

$ ->
  # Artwork autocomplete
  updateArtworkSelectionsForm = (selection) ->
    $( "#artwork_selections_form #submission_source_artwork_id" ).val( selection.id )
    $( "#artwork_selections_form #artwork_search" ).val( selection.title )

  if $('#artwork_selections_form').length != 0
    $('#artwork_selections_form #artwork_search').autocomplete(
      source: (request, response) ->
        $.getJSON('/match_artwork', term: request.term, response)
      focus: (event, ui) ->
        updateArtworkSelectionsForm(ui.item)
        false
      select: (event, ui) ->
        updateArtworkSelectionsForm(ui.item)
        false
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      $( "<li class='ui-menu-item'>" )
        .attr( "data-value", item.value )
        .append( "<a class='ui-corner-all'>#{item.title} (#{item.id})</a>" )
        .appendTo( ul )

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
