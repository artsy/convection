require "restforce"

class SalesforceService
  class << self
    def add_artwork(submission_id)
      return unless api_enabled?

      submission = Submission.find(submission_id)

      sf_contact_id = find_contact_id(submission) || api.create!("Contact", map_submission_to_salesforce_contact(submission))
      sf_artist_id = api.select("Artist__c", submission.artist_id, ["Id"], "Gravity_Artist_ID__c").Id

      api.create!("Artwork__c", map_submission_to_salesforce_artwork(submission, sf_contact_id, sf_artist_id))
    end

    private

    def find_contact_id(submission)
      if submission.user.present?
        api.select("Contact", submission.user.gravity_user_id, ["Id"], "Partner_Contact_Ext_Id__c").Id
      else
        find_contact_id_by_email(submission.user_email)
      end
    rescue Restforce::NotFoundError
      find_contact_id_by_email(submission.user_email)
    end

    def find_contact_id_by_email(user_email)
      api.query("select Id from Contact where Email = '#{user_email}'").first&.Id
    end

    def find_sf_user_id(gravity_id)
      api.select("User", gravity_id, ["Id"], "Admin_User_ID__c").Id
    rescue Restforce::NotFoundError
      nil
    end

    def map_submission_to_salesforce_contact(submission)
      {
        LastName: submission.user_name,
        Email: submission.user_email,
        Partner_Contact_Ext_Id__c: submission.user&.gravity_user_id,
        Phone: submission.user_phone
      }
    end

    def map_submission_to_salesforce_artwork(submission, contact_id, artist_id)
      artwork_rep = {
        Name: submission.title[0..79],
        Artwork_Title__c: submission.title,
        Seller_Contact__c: contact_id,
        Primary_Artist__c: artist_id,
        Artwork_Year__c: submission.year,
        CurrencyIsoCode: submission.currency,
        Price_Listed__c: submission.minimum_price_cents,
        Medium__c: submission.category,
        Materials__c: submission.medium,
        Height__c: submission.height,
        Width__c: submission.width,
        Depth__c: submission.depth,
        Metric__c: submission.dimensions_metric,
        Provenance__c: submission.provenance,
        Condition_Notes__c: submission.condition_report,
        Literature__c: submission.literature,
        Signature_Inscription__c: submission.signature_detail,
        Certificate_Of_Authenticity__c: submission.coa_by_authenticating_body || submission.coa_by_gallery || false,
        COA_by_Gallery__c: submission.coa_by_gallery || false,
        COA_by_Authenticating_Body__c: submission.coa_by_authenticating_body || false,
        Cataloguer__c: submission.cataloguer,
        Primary_Image_URL__c: submission.primary_image&.image_urls&.dig("thumbnail"),
        Convection_ID__c: submission.id,
        Assigned_To__c: find_sf_user_id(submission.assigned_to)
        # Other fields we could sync in the future:
        # Artwork_Status__c: submission.state,
        # Materials: ???
        # Diameter: ???
        # Framed: ???
        # FramedDimensions: ???
        # Previoulsly synced fields:
        # Not_Signed__c: !submission.signature, removed due to cataloguing issues
      }
      # Owner can't be nil, if we can't find it the API will succeed using the default user
      owner_id = find_sf_user_id(submission.approved_by)
      artwork_rep = artwork_rep.merge(OwnerId: owner_id) if owner_id
      artwork_rep
    end

    def api_enabled?
      Convection.config.salesforce_client_id.present? &&
        Convection.config.salesforce_client_secret.present? &&
        Convection.config.salesforce_host.present? &&
        Convection.config.salesforce_username.present? &&
        Convection.config.salesforce_password.present? &&
        Convection.config.salesforce_security_token.present?
    end

    def api
      @api ||= Restforce.new \
        username: Convection.config.salesforce_username,
        password: Convection.config.salesforce_password,
        security_token: Convection.config.salesforce_security_token,
        client_id: Convection.config.salesforce_client_id,
        client_secret: Convection.config.salesforce_client_secret,
        host: Convection.config.salesforce_host,
        api_version: "41.0"
    end
  end
end
