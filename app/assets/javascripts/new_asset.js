function onSuccessfulGeminiUpload ({ token }) {
  var $container = $('#gemini_tokens')
  var currentVal = $container.val()
  var newVal = currentVal + ' ' + token
  $container.val(newVal)
}

function geminiOnDone (e, data) {
  var uid = data.uid
  $(`.uploading_file[data-uid=${uid}] progress`).remove()
}

function geminiOnIndividualFile (e, data) {
  var uid = data.uid
  var fileName = data.files[0].name
  var uploadPercent = "<div><progress value='0' max='100' class='upload_progress_bar'>0</progress></div>"
  $('#uploading_files').append(`<div class='uploading_file' data-uid=${uid}><div class='uploading-file-meta clearfix'><div class='uploading-file-name pull-left'>${fileName} <em><span class='upload_percentage'>0</span>%</em></div></div>${uploadPercent}</div>`)
}

function onFailedGeminiUpload () {
  $('#uploading_failed').html('Failed to upload image.')
}

// Standard jQuery FileUpload progress callback
function geminiOnProgressUpdate (e, data) {
  var uid = data.uid
  var progress = parseInt(data.loaded / data.total * 100, 10)
  $(`.uploading_file[data-uid=${uid}]`).find('.upload_percentage').html(progress)
  $(`.uploading_file[data-uid=${uid}]`).find('.upload_progress_bar').val(progress)
}

$(document).ready(() => {
  var geminiOptions = {
    geminiApp: 'https://media.artsy.net',
    acl: 'private',
    s3Key: 'AKIAIYU72SSZR4W7WQXA',
    templateKey: 'convection-staging',
    geminiKey: 'convection-staging',
    metadata: {
      id: 'submission id',
      _type: 'Consignment'
    },
    onFail: onFailedGeminiUpload,
    onIndividualFile: geminiOnIndividualFile,
    onProgress: geminiOnProgressUpdate,
    successCb: onSuccessfulGeminiUpload,
    onDone: geminiOnDone
  }

  var $geminiContainer = $('#gemini-upload')
  if ($geminiContainer.length) {
    $geminiContainer.geminiUpload(geminiOptions)
    $('#select-gemini-file').click(() => {
      $("input[type='file']").click()
      return
    })
  }
})
