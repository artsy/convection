# frozen_string_literal: true

Money.locale_backend = :i18n

# The default rounding mode used to be `BigDecimal::ROUND_HALF_EVEN':
# https://github.com/RubyMoney/money/pull/863/files#diff-a6d34f32282d8d431a585cdaf0aaf730L159
Money.rounding_mode = BigDecimal::ROUND_HALF_EVEN
