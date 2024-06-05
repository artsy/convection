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

    def salesforce_artwork_for_submission(submission)
      return unless api_enabled? && submission

      api.query(
        <<~SQL
          select Id, Primary_Artist__c, CurrencyIsoCode, Depth__c, Artwork_Title__c, Artwork_Year__c, Diameter__c, Width__c, Height__c, Medium_Type__c, Materials__c, Ecommerce__c, Price_Listed__c, Price_Hidden__c, Certificate_of_Authenticity__c, COA_by_Authenticating_Body__c, COA_by_Gallery__c, Condition_Notes__c, Edition_Information__c, Framed__c, Metric__c, Primary_Image_URL__c, Provenance__c, Signature_Description__c, Signed_by_Artist__c, Signed_in_Plate__c, Signed_Other__c, Not_Signed__c, Artwork_Price_Min__c, Artwork_Price_Max__c, Literature__c, Exhibition_History__c, Edition_Number__c, Size_of_edition__c, Available_works__c
          from Artwork__c
          where Convection_ID__c = '#{submission.id}'
        SQL
      ).first
    end

    def salesforce_artwork_to_artwork_params(salesforce_artwork)
      return unless salesforce_artwork

      {
        artists: [find_artist(salesforce_artwork.Primary_Artist__c)&.Gravity_Artist_ID__c.presence].compact,
        price_currency: salesforce_artwork.CurrencyIsoCode.presence,
        depth: salesforce_artwork.Depth__c.presence,
        title: salesforce_artwork.Artwork_Title__c.presence,
        date: salesforce_artwork.Artwork_Year__c.presence,
        diameter: salesforce_artwork.Diameter__c.presence,
        width: salesforce_artwork.Width__c.presence,
        height: salesforce_artwork.Height__c.presence,
        category: salesforce_artwork.Medium_Type__c.presence,
        medium: salesforce_artwork.Materials__c.presence,
        ecommerce: salesforce_artwork.Ecommerce__c,
        price_listed: salesforce_artwork.Price_Listed__c,
        price_hidden: salesforce_artwork.Price_Hidden__c,
        certificate_of_authenticity: salesforce_artwork.Certificate_of_Authenticity__c,
        coa_by_authenticating_body: salesforce_artwork.COA_by_Authenticating_Body__c,
        coa_by_gallery: salesforce_artwork.COA_by_Gallery__c,
        condition_description: salesforce_artwork.Condition_Notes__c.presence,
        attribution_class: salesforce_artwork.Edition_Information__c.presence,
        framed: salesforce_artwork.Framed__c,
        metric: salesforce_artwork.Metric__c.presence,
        provenance: salesforce_artwork.Provenance__c.presence,
        signature: salesforce_artwork.Signature_Description__c.presence,
        signed_by_artist: salesforce_artwork.Signed_by_Artist__c,
        signed_in_plate: salesforce_artwork.Signed_in_Plate__c,
        signed_other: salesforce_artwork.Signed_Other__c,
        not_signed: salesforce_artwork.Not_Signed__c,
        price_min: salesforce_artwork.Artwork_Price_Min__c.presence,
        price_max: salesforce_artwork.Artwork_Price_Max__c.presence,
        literature: salesforce_artwork.Literature__c.presence,
        exhibition_history: salesforce_artwork.Exhibition_History__c.presence
      }
    end

    def salesforce_artwork_to_edition_set_params(salesforce_artwork)
      return unless salesforce_artwork

      {
        edition_size: salesforce_artwork.Size_of_edition__c.presence,
        available_editions: [salesforce_artwork.Available_works__c.presence].compact,
        height: salesforce_artwork.Height__c.presence,
        width: salesforce_artwork.Width__c.presence,
        depth: salesforce_artwork.Depth__c.presence,
        metric: salesforce_artwork.Metric__c.presence
      }
    end

    def salesforce_artwork_to_image_urls(salesforce_artwork)
      [salesforce_artwork&.Primary_Image_URL__c].compact
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

    def find_artist(salesforce_artist_id)
      return if salesforce_artist_id.blank?
      api.find("Artist__c", salesforce_artist_id)
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
        Medium_Type__c: submission.category,
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
        Primary_Image_URL__c: submission.primary_image&.image_urls&.fetch("large"),
        Additional_Images__c: submission.images.map { |image| image.image_urls["large"] }.join(","),
        Convection_ID__c: submission.id,
        Assigned_To__c: find_sf_user_id(submission.assigned_to),
        Size_of_edition__c: submission.edition_size,
        Available_works__c: submission.edition_number
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
