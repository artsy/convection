# frozen_string_literal: true

require "rails_helper"
require "support/gravity_helper"

describe Submission do
  let(:submission) { Fabricate(:submission) }

  context "state" do
    it "correctly sets the initial state to draft" do
      expect(submission.state).to eq "draft"
    end

    it "allows only certain states" do
      expect(Submission.new(state: "blah")).not_to be_valid
      expect(Submission.new(state: "approved")).to be_valid
      expect(Submission.new(state: "submitted")).to be_valid
    end
  end

  context "scopes" do
    describe "completed" do
      it "returns the number of non-draft submissions" do
        Fabricate(:submission, state: "approved")
        Fabricate(:submission, state: "rejected")
        Fabricate(:submission, state: "draft")
        Fabricate(:submission, state: "submitted")
        expect(Submission.completed.count).to eq(3)
      end

      it "returns 0 if there are only draft submissions" do
        Fabricate(:submission)
        expect(Submission.completed.count).to eq(0)
      end
    end

    describe "available" do
      it "returns only published submissions without an accepted offer" do
        consigned_submission = Fabricate(:submission, state: "published")
        partner_submission =
          Fabricate(:partner_submission, submission: consigned_submission)
        offer = Fabricate(:offer, partner_submission: partner_submission)

        OfferService.consign!(offer)

        Fabricate(:submission, state: "approved")
        published_submission = Fabricate(:submission, state: "published")
        Fabricate(:submission, state: "rejected")
        Fabricate(:submission, state: "draft")
        Fabricate(:submission, state: "submitted")

        available_submissions = Submission.available
        expect(available_submissions.count).to eq(1)
        expect(available_submissions.first).to eq(published_submission)
      end
    end
  end

  context "demand scores" do
    let(:artist_id) { "artistid" }

    let!(:artist_standing_score) do
      Fabricate(
        :artist_standing_score,
        artist_id: artist_id,
        artist_score: 0.50,
        auction_score: 1.0
      )
    end

    let!(:other_standing_score) do
      Fabricate(
        :artist_standing_score,
        artist_id: "other",
        artist_score: 0.33,
        auction_score: 0.66
      )
    end

    let(:submission_state) { "draft" }

    let(:submission) do
      Fabricate(
        :submission,
        artist_id: artist_id,
        medium: "Painting",
        state: submission_state
      )
    end

    it "is set on create" do
      expect(submission.artist_score).to eq artist_standing_score.artist_score
      expect(submission.auction_score).to eq artist_standing_score.auction_score
    end

    context "updating when in draft" do
      it "is re-calculated when category changes" do
        submission.update(category: "Photography")
        submission.reload

        expect(submission.artist_score).to eq 0.25
        expect(submission.auction_score).to eq 0.5
      end

      it "is re-calculated when artist id changes" do
        submission.update(artist_id: "other")

        expect(submission.artist_score).to eq other_standing_score.artist_score
        expect(submission.auction_score).to eq other_standing_score
             .auction_score
      end

      it "does not re-calcuate when unrelated things change" do
        expect(DemandCalculator).to receive(:score).and_return({}).once
        submission.update(title: "Some great work")
      end
    end

    context "updating when not draft" do
      let(:submission_state) { "approved" }

      it "does not re-calculate" do
        submission.update(artist_id: "other")

        expect(submission.artist_score).to eq artist_standing_score.artist_score
        expect(submission.auction_score).to eq artist_standing_score
             .auction_score
      end
    end

    context "updating away from draft" do
      it "does not re-calculate" do
        submission.update(artist_id: "other", state: "approved")

        expect(submission.artist_score).to eq artist_standing_score.artist_score
        expect(submission.auction_score).to eq artist_standing_score
             .auction_score
      end
    end
  end

  context "category" do
    it "allows only certain categories" do
      expect(Submission.new(category: nil)).to be_valid
      expect(Submission.new(category: "blah")).not_to be_valid
      expect(Submission.new(category: "Painting")).to be_valid
    end
  end

  context "dimensions_metric" do
    it "allows only certain categories" do
      expect(Submission.new(dimensions_metric: nil)).to be_valid
      expect(Submission.new(dimensions_metric: "blah")).not_to be_valid
      expect(Submission.new(dimensions_metric: "in")).to be_valid
      expect(Submission.new(dimensions_metric: "cm")).to be_valid
    end
  end

  context "processed_images" do
    it "returns an empty array if there are no images" do
      expect(submission.processed_images).to eq []
    end

    it "returns an empty array if there are no processed images" do
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.processed_images).to eq []
    end

    it "returns only the processed images" do
      asset1 = Fabricate(:image, submission: submission)
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.processed_images).to eq [asset1]
    end
  end

  context "finished_processing_images_for_email?" do
    it "returns true if there are no assets" do
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it "returns true if all of the assets have a square url" do
      2.times { Fabricate(:image, submission: submission) }
      expect(submission.finished_processing_images_for_email?).to eq true
    end

    it "returns false if only some of the images have a square url" do
      Fabricate(:image, submission: submission)
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.finished_processing_images_for_email?).to eq false
    end

    it "returns false if none of the images have a square url" do
      2.times { Fabricate(:unprocessed_image, submission: submission) }
      expect(submission.finished_processing_images_for_email?).to eq false
    end
  end

  context "thumbnail" do
    it "returns nil if there is no thumbnail image" do
      Fabricate(:unprocessed_image, submission: submission)
      expect(submission.thumbnail).to eq nil
    end
    it "returns nil if there are no assets" do
      expect(submission.thumbnail).to eq nil
    end
    it "returns the thumbnail url for the primary image" do
      image = Fabricate :image, submission: submission
      submission.update!(primary_image: image)
      expect(submission.thumbnail).to eq image.image_urls["thumbnail"]
    end
  end

  context "real deletion (destroy)" do
    it "deletes associated partner submissions and offers" do
      Fabricate(:partner_submission, submission: submission)
      Fabricate(:offer, submission: submission)
      expect { submission.destroy }.to change { PartnerSubmission.count }.by(
        -1
      ).and change { Offer.count }.by(-1)
    end
  end

  context "count_submissions_of_user" do
    context "if user exist" do
      let(:user) { Fabricate(:user) }
      let!(:submission) { Fabricate(:submission, user: user) }
      let!(:submission1) { Fabricate(:submission, user: user) }
      let!(:out_of_sample_submission) { Fabricate(:submission, user: nil) }

      it "returns the count of user submissions eq 1" do
        submission1.delete
        expect(submission.count_submissions_of_user).to eq 1
      end

      it "returns the count of user submissions eq 2" do
        expect(submission.count_submissions_of_user).to eq 2
      end
    end

    context "if anonymous submission" do
      let!(:submission) do
        Fabricate(:submission, user: nil, user_email: "user@artsymail.com")
      end
      let!(:submission1) do
        Fabricate(:submission, user: nil, user_email: "user@artsymail.com")
      end
      let!(:out_of_sample_submission) do
        Fabricate(:submission, user: nil, user_email: "diff_user@artsymail.com")
      end
      let!(:submission_without_email_and_user) do
        Fabricate(:submission, user: nil, user_email: nil)
      end

      it "return the count of user submissions found by user_email eq 1" do
        submission1.delete
        expect(submission.count_submissions_of_user).to eq 1
      end

      it "return the count of user submissions found by user_email eq 2" do
        expect(submission.count_submissions_of_user).to eq 2
      end

      it "return 1 submission if submission without a user and does not have user_email" do
        expect(
          submission_without_email_and_user.count_submissions_of_user
        ).to eq 1
      end
    end
  end
end
