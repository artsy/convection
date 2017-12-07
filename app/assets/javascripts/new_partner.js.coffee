$ ->
  # Partner autocomplete
  updatePartnerSelectionsForm = (selection) ->
    $( "#partner-selections-form #gravity_partner_id" ).val( selection.id )
    $( "#partner-selections-form #name" ).val( selection.given_name )
    $( "#partner-selections-form #partner-search" ).val( selection.given_name )
    $( "#partner-selections-form #partner-name-display" ).html('Selected partner: ' + selection.given_name)
    enableDisableButton()

  enableDisableButton = () ->
    if $('#partner-selections-form #gravity_partner_id').val().length > 0
      $('#partner-selections-form #partner-search-submit').removeClass('disabled-button')
    else
      $('#partner-selections-form #partner-search-submit').addClass('disabled-button')

  if $('#partner-selections-form').length != 0
    enableDisableButton()
    $('#partner-selections-form #partner-search').autocomplete(
      source: (request, response) ->
        $.getJSON('/match_partner', term: request.term, response)
      select: (event, ui) ->
        updatePartnerSelectionsForm(ui.item)
        false
    ).data("ui-autocomplete")._renderItem = (ul, item) ->
      $( "<li class='ui-menu-item'>" )
        .attr( "data-value", item.value )
        .append( "<a class='ui-corner-all'>#{item.given_name}</a>" )
        .appendTo( ul )
