class ModifyOffersTable < ActiveRecord::Migration[5.2]
  def up
    change_table :offers, bulk: true do |t|
      t.rename(:photography_cents, :photography_info)
      t.rename(:shipping_cents, :shipping_info)
      t.rename(:insurance_cents, :insurance_info)
      t.rename(:other_fees_cents, :other_fees_info)

      t.change(
        :photography_info,
        :string,
        using:
          'CASE WHEN (photography_info IS NOT NULL) ' \
            "THEN format('%s %s', TRIM(to_char(photography_info / 100, '99999')), currency) END"
      )
      t.change(
        :shipping_info,
        :string,
        using:
          'CASE WHEN (shipping_info IS NOT NULL) ' \
            "THEN format('%s %s', TRIM(to_char(shipping_info / 100, '99999')), currency) END"
      )
      t.change(
        :insurance_info,
        :string,
        using:
          'CASE WHEN (insurance_info IS NOT NULL) ' \
            "THEN format('%s %s', TRIM(to_char(insurance_info / 100, '99999')), currency) " \
            'WHEN (insurance_percent IS NOT NULL) ' \
            "THEN TRIM(TO_CHAR(insurance_percent * 100, '99D00%')) END"
      )
      t.change(
        :other_fees_info,
        :string,
        using:
          'CASE WHEN (other_fees_info IS NOT NULL) ' \
            "THEN format('%s %s', TRIM(to_char(other_fees_info / 100, '99999')), currency) " \
            'WHEN (other_fees_percent IS NOT NULL) ' \
            "THEN TRIM(TO_CHAR(other_fees_percent * 100, '99D00%')) END"
      )

      t.column(:deadline_to_consign, :string)

      t.remove(:insurance_percent)
      t.remove(:other_fees_percent)
    end
  end

  def down
    change_table :offers, bulk: true do |t|
      t.column(:insurance_percent, :float)
      t.column(:other_fees_percent, :float)

      t.remove(:deadline_to_consign)

      t.change(
        :photography_info,
        :integer,
        using:
          "CASE WHEN (photography_info ~ '^\d+$') THEN photography_info::integer ELSE null END"
      )
      t.change(
        :shipping_info,
        :integer,
        using:
          "CASE WHEN (shipping_info ~ '^\d+$') THEN shipping_info::integer ELSE null END"
      )
      t.change(
        :insurance_info,
        :integer,
        using:
          "CASE WHEN (insurance_info ~ '^\d+$') THEN insurance_info::integer ELSE null END"
      )
      t.change(
        :other_fees_info,
        :integer,
        using:
          "CASE WHEN (other_fees_info ~ '^\d+$') THEN other_fees_info::integer ELSE null END"
      )

      t.rename(:photography_info, :photography_cents)
      t.rename(:shipping_info, :shipping_cents)
      t.rename(:insurance_info, :insurance_cents)
      t.rename(:other_fees_info, :other_fees_cents)
    end
  end
end
