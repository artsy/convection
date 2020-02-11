module Dollarize
  extend ActiveSupport::Concern

  # Call like:
  #   dollarize :low_estimate_cents  # => defines low_estimate_dollars and low_estimate_display
  #
  class_methods do
    def dollarize(*method_names)
      method_names.each do |method_name|
        attribute method_name.to_s.gsub(/_cents$/, '_dollars').to_sym

        define_method method_name.to_s.gsub(/_cents$/, '_dollars') do
          return if self[method_name].blank?

          self[method_name] / 100
        end

        define_method "#{method_name.to_s.gsub(/_cents$/, '_dollars')}=" do |dollars|
          cents = if dollars.blank?
                    nil
                  elsif dollars.is_a?(String)
                    dollars.gsub(',', '').to_f * 100
                  else
                    dollars.to_f * 100
                  end

          self[method_name] = cents
        end

        define_method method_name.to_s.gsub(/_cents$/, '_display') do
          return if self[method_name].blank?

          currency = self.currency || 'USD'
          Money.new(self[method_name], currency).format(no_cents: true)
        end
      end
    end
  end
end
