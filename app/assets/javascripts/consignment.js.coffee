$ ->
  updateCanceledReasonDisplay = ($selectInput) ->
    if $selectInput.val() == 'canceled'
      $('.canceled-reason-field').removeClass('hidden')
    else
      $('.canceled-reason-field').addClass('hidden')

  if $('select[name="partner_submission[state]"]').length > 0
    $selectInput = $('select[name="partner_submission[state]"]')
    updateCanceledReasonDisplay($selectInput)

    # Show canceled reason input only if "canceled" is selected as the state
    $selectInput.on 'change', ->
      updateCanceledReasonDisplay($selectInput)
