$ ->
  # Enable complete button only if checkbox is checked
  $('input[name="terms_signed"]').on 'click', ->
    if $(this).is(':checked')
      $('.offer-consign-button').removeClass('disabled-button')
    else
      $('.offer-consign-button').addClass('disabled-button')
