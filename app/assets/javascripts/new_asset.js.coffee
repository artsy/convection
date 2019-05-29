$ ->
  onSuccessfulGeminiUpload = (data) ->
    token = data.token
    $container = $('#gemini_tokens')
    currentVal = $container.val()
    newVal = currentVal + ' ' + token
    $container.val(newVal)

  geminiOnDone = (e, data) ->
    uid = data.uid
    $(".uploading_file[data-uid=#{uid}] progress").remove()

  geminiOnIndividualFile = (e, data) =>
    uid = data.uid
    fileName = data.files[0].name
    uploadPercent = "<div><progress value='0' max='100' class='upload_progress_bar'>0</progress></div>"
    $('#uploading_files').append("<div class='uploading_file' data-uid=#{uid}><div class='uploading-file-meta clearfix'><div class='uploading-file-name pull-left'>#{fileName }<em><span class='upload_percentage'>0</span>%</em></div></div>#{uploadPercent}</div>")

  onFailedGeminiUpload = () ->
    $('#uploading_failed').html('Failed to upload image.')

  geminiOnProgressUpdate = (e, data) ->
    uid = data.uid
    progress = parseInt(data.loaded / data.total * 100, 10)
    $(".uploading_file[data-uid=#{uid}]").find('.upload_percentage').html(progress)
    $(".uploading_file[data-uid=#{uid}]").find('.upload_progress_bar').val(progress)

  $geminiContainer = $('#gemini-upload')

  if $geminiContainer.length > 0
    submissionId = $('#submission_id').val()
    metadata =
      id: submissionId
      _type: 'Consignment'

    geminiOptions =
      geminiApp: window.GEMINI_APP
      acl: 'private'
      templateKey: window.GEMINI_ACCOUNT_KEY
      geminiKey: window.GEMINI_ACCOUNT_KEY
      metadata: metadata
      onFail: onFailedGeminiUpload
      onIndividualFile: geminiOnIndividualFile
      onProgress: geminiOnProgressUpdate
      successCb: onSuccessfulGeminiUpload
      onDone: geminiOnDone

    $geminiContainer.geminiUpload(geminiOptions)
    $('#select-gemini-file').click ->
      $("input[type='file']").click()
      return
