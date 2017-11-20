module Util
  class AuthorizationInstrumentation
    def instrument(_type, field)
      return field unless requires_authorization?(field)
      old_resolve_proc = field.resolve_proc
      new_resolve_proc = ->(obj, args, ctx) do
        if can_access?(field, ctx)
          resolved = old_resolve_proc.call(obj, args, ctx)
          resolved
        else
          err = GraphQL::ExecutionError.new("Can't access #{field.name}")
          ctx.add_error(err)
        end
      end

      field.redefine do
        resolve(new_resolve_proc)
      end
    end

    def requires_authorization?(field)
      field.metadata[:permit].present?
    end

    def can_access?(field, ctx)
      return false unless ctx[:current_user_roles] && ctx[:current_application]
      !(ctx[:current_user_roles] & [field.metadata[:permit]].flatten).empty?
    end
  end
end
