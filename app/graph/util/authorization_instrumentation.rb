module Util
  class AuthorizationInstrumentation
    def instrument(_type, field)
      return field unless requires_authorization?(field)

      old_resolve_proc = field.resolve_proc
      new_resolve_proc = lambda do |obj, args, ctx|
        if field.metadata[:permit].present? && !can_access?(field, ctx)
          err = GraphQL::ExecutionError.new("Can't access #{field.name}")
          ctx.add_error(err)
        end

        # Handle args with permissions
        auth_args =
          field.arguments.values.select do |arg|
            arg.metadata && arg.metadata[:permit]
          end
        failing_args = auth_args.reject { |arg| can_access?(arg, ctx) }
        unless failing_args.empty?
          err =
            GraphQL::ExecutionError.new(
              "Can't access arguments: #{failing_args.map(&:name).join(',')}"
            )
          ctx.add_error(err)
        end

        if ctx.errors.empty?
          resolved = old_resolve_proc.call(obj, args, ctx)
          resolved
        end
      end
      # Handle fields with permissions

      field.redefine { resolve(new_resolve_proc) }
    end

    def requires_authorization?(field)
      field.metadata[:permit].present? ||
        field.arguments.values.find do |arg|
          arg.metadata && arg.metadata[:permit]
        end
    end

    def can_access?(attribute, ctx)
      return false unless ctx[:current_user_roles] && ctx[:current_application]

      !(ctx[:current_user_roles] & [attribute.metadata[:permit]].flatten).empty?
    end
  end
end
