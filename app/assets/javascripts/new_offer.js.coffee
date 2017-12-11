$ ->

  # Choose a partner to associate with an offer
  formatPartner = (partner) ->
    partner.name

  $('#new-offer-partner').select2(
    ajax: {
      url: '/admin/partners',
      dataType: 'json',
      data: (params) ->
        term: params.term
      processResults: (data, params) ->
        results: data
    },
    allowClear: true,
    placeholder: 'Select a partner',
    minimumInputLength: 1,
    width: 'element',
    templateResult: formatPartner,
    templateSelection: formatPartner
  ).on('select2:select', (event) ->
    $( '#partner_id' ).val( event.params.data.id )
  ).on('select2:unselect', () ->
    $( '#partner_id' ).val('')
  ).val($('#partner_id').val()).trigger('change')

  # Choose the submission to create an offer for
  formatSubmission = (submission) ->
    console.log('formatting?', submission)
    submission.id + ' (' + submission.title + ')'

  $('#new-offer-submission').select2(
    ajax: {
      url: '/admin/submissions',
      dataType: 'json',
      data: (params) ->
        term: params.term
      processResults: (data, params) ->
        results: data
    },
    allowClear: true,
    placeholder: 'Select a submission',
    minimumInputLength: 1,
    width: 'element',
    templateResult: formatSubmission,
    templateSelection: formatSubmission
  ).on('select2:select', (event) ->
    $( '#submission_id' ).val( event.params.data.id )
  ).on('select2:unselect', () ->
    $( '#submission_id' ).val('')
  ).val($('#submission_id').val()).trigger('change')
