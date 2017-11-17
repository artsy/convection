module Util
  class PermissionBlacklist
    def self.call(schema_member, context)
      return context[:current_user].blank? if schema_member.name == 'user_id'
    end
  end
end
