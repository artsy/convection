# Recreate some of our FK constraints to add ON DELETE clauses, because we 
# were unable to delete a test offer in the production database when requested.

# The original SQL:
#
#   ALTER TABLE offers 
#     DROP CONSTRAINT fk_rails_80eb82ccbf, 
#     ADD CONSTRAINT fk_rails_80eb82ccbf FOREIGN KEY (partner_submission_id) REFERENCES partner_submissions(id) ON DELETE CASCADE;

#   ALTER TABLE offers 
#     DROP CONSTRAINT fk_rails_bb4a8a64be, 
#     ADD CONSTRAINT fk_rails_bb4a8a64be FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE CASCADE;

#   ALTER TABLE partner_submissions 
#     DROP CONSTRAINT fk_rails_7d3e140ff6, 
#     ADD CONSTRAINT fk_rails_7d3e140ff6 FOREIGN KEY (accepted_offer_id) REFERENCES offers(id) ON DELETE CASCADE;

#   ALTER TABLE submissions 
#     DROP CONSTRAINT fk_rails_750bb63f9c, 
#     ADD CONSTRAINT fk_rails_750bb63f9c FOREIGN KEY (consigned_partner_submission_id) REFERENCES partner_submissions(id) ON DELETE SET NULL;



class UpdateForeignKeys < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key "offers", "partner_submissions"
    add_foreign_key "offers", "partner_submissions", on_delete: :cascade

    remove_foreign_key "offers", "submissions"
    add_foreign_key "offers", "submissions", on_delete: :cascade

    remove_foreign_key "partner_submissions", column: "accepted_offer_id"
    add_foreign_key "partner_submissions", "offers", column: "accepted_offer_id", on_delete: :cascade

    remove_foreign_key "submissions", column: "consigned_partner_submission_id"
    add_foreign_key "submissions", "partner_submissions", column: "consigned_partner_submission_id", on_delete: :nullify

  end

  def down
    remove_foreign_key "offers", "partner_submissions"
    add_foreign_key "offers", "partner_submissions"

    remove_foreign_key "offers", "submissions"
    add_foreign_key "offers", "submissions"

    remove_foreign_key "partner_submissions", column: "accepted_offer_id"
    add_foreign_key "partner_submissions", "offers", column: "accepted_offer_id"

    remove_foreign_key "submissions", column: "consigned_partner_submission_id"
    add_foreign_key "submissions", "partner_submissions", column: "consigned_partner_submission_id"
  end
end
