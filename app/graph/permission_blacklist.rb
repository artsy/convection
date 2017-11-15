class PermissionBlacklist
  def self.call(schema_member, context)
    if schema_member.name == 'user_id'
      return context[:current_user].blank?
    end
  end
end
