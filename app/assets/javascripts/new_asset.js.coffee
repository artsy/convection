generateUid = () ->
  chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
  Array(16)
    .join()
    .split(',')
    .map(() -> chars.charAt(Math.floor(Math.random() * chars.length)) )
    .join('')

addGeminiTokensToForm = (data) ->
  token = data.token
  $container = $('#gemini_tokens')
  index = $container.find('input').length
  $container.append("<input type='hidden' name='gemini_tokens[#{index}]' value='#{token}' />")

addAdditionalFileKeysToForm = () ->
  form = $('#s3-upload')
  $container = $('#addition_file_keys')
  s3Key = form.find('input[name=key]').val()
  index = $container.find('input').length
  $container.append("<input type='hidden' name='additional_file_keys[#{index}]' value='#{s3Key}' />")

addAdditionalFileNamesToForm = (data) ->
  form = $('#s3-upload')
  $container = $('#addition_file_names')
  fileName = data.files[0].name
  index = $container.find('input').length
  $container.append("<input type='hidden' name='additional_file_names[#{index}]' value='#{fileName}' />")

removeProgress = (e, data) ->
  uid = data.uid
  $(".uploading_file[data-uid=#{uid}] progress").remove()

addProgressLine = (e, data) ->
  uid = data.uid
  fileName = data.files[0].name
  uploadPercent = "<div><progress value='0' max='100' class='upload_progress_bar'>0</progress></div>"
  $('#uploading_files').append("<div class='uploading_file' data-uid=#{uid}><div class='uploading-file-meta clearfix'><div class='uploading-file-name pull-left'>#{fileName } <em><span class='upload_percentage'>0</span>%</em></div></div>#{uploadPercent}</div>")

onFailedUpload = () ->
  $('#uploading_failed').html('Failed to upload image.')

onProgressUpdate = (e, data) ->
  uid = data.uid
  progress = parseInt(data.loaded / data.total * 100, 10)
  $(".uploading_file[data-uid=#{uid}]").find('.upload_percentage').html(progress)
  $(".uploading_file[data-uid=#{uid}]").find('.upload_progress_bar').val(progress)

seedAdditionalFileUploadForm = (submissionId) ->
  form = $('#s3-upload')
  form.fileupload({
    type: 'POST',
    dataType: 'xml',
    add: (e, data) ->
      uid = generateUid()
      _.extend data, { uid: uid }

      addProgressLine(e, data)

      fileType = data.files[0].type
      form.find("input[name='Content-Type']").val(fileType)
      key = form.find('input[name=key]')
      key.val key.val().replace(/[^\/]+$/, uid)

      data.submit()
    done: (e, data) ->
      removeProgress(e, data)
      addAdditionalFileKeysToForm()
      addAdditionalFileNamesToForm(data)
    fail: () -> onFailedUpload()
    progress: (e, data) -> onProgressUpdate(e, data)
  })

$ ->
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
    onFail: onFailedUpload
    onIndividualFile: addProgressLine
    onProgress: onProgressUpdate
    successCb: addGeminiTokensToForm
    onDone: removeProgress

  # giminiUpload comes from https://github.com/artsy/gemini_upload-rails
  #   - it prepares _gemini_form.html.erb - populates it with correct
  #     Gemini credentials for s3 uploads
  #   - inclides all upload flow logic (progress, on error, etc.)
  $('#gemini-upload').geminiUpload(geminiOptions)

  # Prepares _s3_form.html.erb to upload files using jquery-file-upload
  seedAdditionalFileUploadForm(submissionId)

  # We have two different forms depending on the asset type
  # "image" uses gemini (and it's credentials to upload to s3)
  # "additional_files" uses Convection's S3 credentials
  # At this stage both forms are already pre-initialized with all
  # required (by jquery-file-upload) fields, so we just need to
  # select the right file input.
  $('#select-gemini-file').click ->
    if $("#asset_type").val() == "image"
      $("input[id='gemini-input']").click()
      return
    else if $("#asset_type").val() == "additional_file"
      $("input[id='s3-input']").click()
      return
  
  # When changing asset type, we reset:
  #  - gemini tokens, additional file keys, so that we don't submit them
  #  - uploading files list (progress bars, errors)
  $('#asset_type').change ->
    # TODO: remove inputs
    $('#gemini_tokens').empty()
    $('#addition_file_keys').empty()
    $('#addition_file_names').empty()

    $('#uploading_files').empty()
    $('#uploading_failed').empty()
