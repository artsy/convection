# frozen_string_literal: true

require 'rails_helper'

describe Types::SortType do
  describe 'prepare' do
    context 'with an ascending sort' do
      it 'returns the correct sort column and direction' do
        prepare_callback = Types::SortType.prepare
        sort_order = prepare_callback.call('CREATED_AT_ASC', nil)
        expect(sort_order).to eq('created_at' => 'asc')
      end
    end

    context 'with a descending sort' do
      it 'returns the correct sort column and direction' do
        prepare_callback = Types::SortType.prepare
        sort_order = prepare_callback.call('CREATED_AT_DESC', nil)
        expect(sort_order).to eq('created_at' => 'desc')
      end
    end
  end
end
