var $;
$ = jQuery;
$.fn.extend({
  geminiUpload: function(options) {
    var encodedCredentials;
    encodedCredentials = this.encode(options.geminiKey, '');
    return $.ajax({
      type: 'GET',
      dataType: 'json',
      url: "" + options.geminiApp + "/uploads/new.json",
      data: {
        acl: options.acl
      },
      headers: {
        'Authorization': "Basic " + encodedCredentials
      },
      success: (function(_this) {
        return function(resp) {
          return _this.attachFileUploadUI(resp, _.extend(options, {
            credentials: encodedCredentials
          }));
        };
      })(this)
    });
  },
  encode: function(key, secret) {
    return btoa(unescape(encodeURIComponent([key, secret].join(':'))));
  },
  uid: function() {
    var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    return Array(16).join().split(',').map(function() { return chars.charAt(Math.floor(Math.random() * chars.length)); }).join('');
  },
  seedForm: function(data, options) {
    var $form, acl, base64Policy, bucket, key, s3Key, signature, successAction, uploadBucket;
    bucket = data.policy_document.conditions[0].bucket;
    key = "" + data.policy_document.conditions[1][2] + "/${filename}";
    acl = data.policy_document.conditions[2].acl;
    successAction = data.policy_document.conditions[3].success_action_status;
    base64Policy = data.policy_encoded;
    signature = data.signature;
    s3Key = options.s3Key;
    uploadBucket = bucket;
    $form = this.find('form');
    $form.find('input[name=key]').val(key);
    $form.find('input[name=AWSAccessKeyId]').val(s3Key);
    $form.find('input[name=acl]').val(acl);
    $form.find('input[name=success_action_status]').val(successAction);
    $form.find('input[name=policy]').val(base64Policy);
    $form.find('input[name=signature]').val(signature);
    if (typeof options.multiple != 'undefined' && options.multiple) {
      $form.find('input[name=file]').attr('multiple', true);
    }
    return $form.get(0).setAttribute('action', "https://" + uploadBucket + ".s3.amazonaws.com");
  },
  makeGeminiApiCall: function(data, originalKey, bucket, options, metadata) {
    var key = originalKey.replace('${filename}', data.uid);
    return $.ajax({
      type: 'POST',
      dataType: 'json',
      url: "" + options.geminiApp + "/entries.json",
      data: {
        entry: {
          source_key: key,
          source_bucket: bucket,
          template_key: options.templateKey,
          metadata: metadata,
          extract_geometry: options.extractGeometry
        }
      },
      headers: {
        'Authorization': "Basic " + options.credentials
      },
      success: function(resp) {
        if (typeof options.successCb != 'undefined' && options.successCb != null) {
          options.successCb(resp, metadata);
        }
      }
    });
  },
  attachFileUploadUI: function(data, options) {
    var $form, bucket, key, metadata, originalKey;

    $form = this.find('form');
    _.defaults(options, {pasteZone: undefined, dropZone: $form});
    bucket = data.policy_document.conditions[0].bucket;
    originalKey = "" + data.policy_document.conditions[1][2] + "/${filename}";
    this.seedForm(data, options);

    return $form.fileupload({
      type: 'POST',
      dataType: 'xml',
      pasteZone: options.pasteZone,
      dropZone: options.dropZone,
      done: (function(_this) {
        return function(e, data) {
          var fileName;
          if (typeof options.onDone != 'undefined' && options.onDone != null) {
            if (typeof options.useDataFromDone != 'undefined' && options.useDataFromDone) {
              options.onDone(e, data, originalKey, bucket, options, _this.makeGeminiApiCall)
            }
            else {
              options.onDone(e, data);
              _this.makeGeminiApiCall(data, originalKey, bucket, options, options.metadata);
            }
          }
        };
      })(this),
      add: (function(_this) {
        return function(e, data) {
          var fileName, fileType, uid, $key;
          uid = _this.uid();
          _.extend(data, { uid: uid });
          if (typeof options.onIndividualFile != 'undefined' && options.onIndividualFile != null) {
            options.onIndividualFile(e, data);
          }
          fileName = data.files[0].name;
          fileType = data.files[0].type;
          $(_this).find("form input[name='Content-Type']").val(fileType);
          $key = $form.find('input[name=key]');
          $key.val($key.val().replace(/[^\/]+$/, uid));
          return data.submit();
        };
      })(this),
      fail: options.onFail,
      progress: options.onProgress
    });
  }
});