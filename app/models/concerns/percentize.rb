# frozen_string_literal: true

module Percentize
  extend ActiveSupport::Concern

  # Call like:
  #   percentize :commission_percent  # => defines commission_percent_whole
  #
  class_methods do
    def percentize(*method_names)
      method_names.each do |method_name|
        attribute "#{method_name}_whole".to_sym

        define_method "#{method_name}_whole" do
          return if self[method_name].blank?

          (self[method_name] * 100).round(2)
        end

        define_method "#{method_name}_whole=" do |percent_whole|
          if percent_whole.blank?
            self[method_name] = nil
          else
            percentage = percent_whole.to_f / 100
            self[method_name] = percentage
          end
        end
      end
    end
  end
end
