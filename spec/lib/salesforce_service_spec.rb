require 'rails_helper'

describe SalesforceService do
  describe '.add_artwork' do
    let(:submission) { Fabricate(:submission) }

    context 'when the integration is not enabled' do
      it 'does not call the Salesforce api' do
        allow(Convection.config).to receive(:salesforce_client_secret).and_return(nil)
        expect(Restforce).to_not receive(:new)
        described_class.add_artwork(submission.id)
      end
    end

    context 'when the integration is enabled' do
      let(:restforce_double) { double }
      before do
        allow(Convection.config).to receive(:salesforce_username).and_return('user')
        allow(Convection.config).to receive(:salesforce_password).and_return('password')
        allow(Convection.config).to receive(:salesforce_security_token).and_return('token')
        allow(Convection.config).to receive(:salesforce_client_id).and_return('id')
        allow(Convection.config).to receive(:salesforce_client_secret).and_return('secret')
        allow(Convection.config).to receive(:salesforce_host).and_return('host')
        allow(described_class).to receive(:api).and_return(restforce_double)
      end

      let(:artwork_as_salesforce_representation) do
        {
          Name: submission.title,
          Seller_Contact__c: 'SF_Contact_ID',
          Primary_Artist__c: 'SF_Artist_ID',
          Artwork_Year__c: submission.year,
          CurrencyIsoCode: submission.currency,
          Price_Listed__c: submission.minimum_price_cents,
          Medium__c: submission.medium,
          Height__c: submission.height,
          Width__c: submission.width,
          Depth__c: submission.depth,
          Metric__c: submission.dimensions_metric,
          Provenance__c: submission.provenance,
          Condition_Notes__c: submission.condition_report,
          Literature__c: submission.literature,
          Signature_Inscription__c: submission.signature_detail,
          Certificate_Of_Authenticity__c: submission.coa_by_authenticating_body || submission.coa_by_gallery || false,
          Not_Signed__c: !submission.signature,
          COA_by_Gallery__c: submission.coa_by_gallery || false,
          COA_by_Authenticating_Body__c: submission.coa_by_authenticating_body || false,
          Cataloguer__c: submission.cataloguer,
          Primary_Image_URL__c: submission.primary_image&.image_urls&.dig('thumbnail'),
          Convection_ID__c: submission.id
        }
      end
      let(:contact_as_salesforce_representation) do
        {
          LastName: submission.user_name,
          Email: submission.user_email,
          Partner_Contact_Ext_Id__c: submission.user&.gravity_user_id,
          Phone: submission.user_phone
        }
      end

      it 'calls the Salesforce api with the correct params' do
        expect(restforce_double).to receive(:select).with(
          'Contact', submission.user.gravity_user_id, ['Id'], 'Partner_Contact_Ext_Id__c'
        ).and_return(OpenStruct.new({ Id: 'SF_Contact_ID'}))

        expect(restforce_double).to receive(:select).with(
          'Artist__c', submission.artist_id, ['Id'], 'Gravity_Artist_ID__c'
        ).and_return(OpenStruct.new({ Id: 'SF_Artist_ID'}))

        expect(restforce_double).to receive(:create!).with(
          'Artwork__c', artwork_as_salesforce_representation,
        ).and_return('SF_Artwork_ID')

        described_class.add_artwork(submission.id)
      end

      context 'when the salesforce contact is not found by id' do
        context 'when the salesforce contact is not found by email' do
          it 'creates a contact in Salesforce, then assigns it to the artwork when creating it' do
            expect(restforce_double).to receive(:select).with(
              'Contact', submission.user.gravity_user_id, ['Id'], 'Partner_Contact_Ext_Id__c'
            ).and_raise(Restforce::NotFoundError, 'TestError')

            expect(restforce_double).to receive(:query).with(
              "select Id from Contact where Email = '#{submission.user_email}'"
            ).and_return([])
  
            expect(restforce_double).to receive(:create!).with(
              'Contact', contact_as_salesforce_representation,
            ).and_return('SF_Contact_ID')
  
            expect(restforce_double).to receive(:select).with(
              'Artist__c', submission.artist_id, ['Id'], 'Gravity_Artist_ID__c'
            ).and_return(OpenStruct.new({ Id: 'SF_Artist_ID'}))
  
            expect(restforce_double).to receive(:create!).with(
              'Artwork__c', artwork_as_salesforce_representation,
            ).and_return('SF_Artwork_ID')
  
            described_class.add_artwork(submission.id)
          end
        end

        context 'when the salesforce contact is found by email' do
          it 'assigns it to the artwork when creating it' do
            expect(restforce_double).to receive(:select).with(
              'Contact', submission.user.gravity_user_id, ['Id'], 'Partner_Contact_Ext_Id__c'
            ).and_raise(Restforce::NotFoundError, 'TestError')

            expect(restforce_double).to receive(:query).with(
              "select Id from Contact where Email = '#{submission.user_email}'"
            ).and_return([OpenStruct.new({ Id: 'SF_Contact_ID'})])
  
            expect(restforce_double).to receive(:select).with(
              'Artist__c', submission.artist_id, ['Id'], 'Gravity_Artist_ID__c'
            ).and_return(OpenStruct.new({ Id: 'SF_Artist_ID'}))
  
            expect(restforce_double).to receive(:create!).with(
              'Artwork__c', artwork_as_salesforce_representation,
            ).and_return('SF_Artwork_ID')
  
            described_class.add_artwork(submission.id)
          end
        end
      end

      context 'when the submission does not have a user' do
        let(:submission) { Fabricate(:submission, user: nil) }

        context 'when the salesforce contact is found by email' do
          it 'assigns it to the artwork when creating it' do
            expect(restforce_double).to receive(:query).with(
              "select Id from Contact where Email = '#{submission.user_email}'"
            ).and_return([OpenStruct.new({ Id: 'SF_Contact_ID'})])
  
            expect(restforce_double).to receive(:select).with(
              'Artist__c', submission.artist_id, ['Id'], 'Gravity_Artist_ID__c'
            ).and_return(OpenStruct.new({ Id: 'SF_Artist_ID'}))
  
            expect(restforce_double).to receive(:create!).with(
              'Artwork__c', artwork_as_salesforce_representation,
            ).and_return('SF_Artwork_ID')
  
            described_class.add_artwork(submission.id)
          end
        end

        context 'when the salesforce contact is not found by email' do
          it 'creates a contact in Salesforce, then assigns it to the artwork when creating it' do
            expect(restforce_double).to receive(:query).with(
              "select Id from Contact where Email = '#{submission.user_email}'"
            ).and_return([])

            expect(restforce_double).to receive(:create!).with(
              'Contact', contact_as_salesforce_representation,
            ).and_return('SF_Contact_ID')
  
            expect(restforce_double).to receive(:select).with(
              'Artist__c', submission.artist_id, ['Id'], 'Gravity_Artist_ID__c'
            ).and_return(OpenStruct.new({ Id: 'SF_Artist_ID'}))
  
            expect(restforce_double).to receive(:create!).with(
              'Artwork__c', artwork_as_salesforce_representation,
            ).and_return('SF_Artwork_ID')
  
            described_class.add_artwork(submission.id)
          end
        end
      end
    end
  end
end
