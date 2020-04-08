# frozen_string_literal: true

require 'rails_helper'

describe 'submissions query with pagination' do
  let(:token) do
    JWT.encode(
      { aud: 'gravity', sub: 'userid', roles: 'admin' },
      Convection.config.jwt_secret
    )
  end

  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  def buildQuery(criteria = 'first: 10')
    <<-GRAPHQL
    query {
      submissions(#{criteria}) {
        edges {
          cursor
          node {
            id
          }
        }
        pageCursors {
          first {
            cursor
            isCurrent
            page
          },
          last {
            cursor
            isCurrent
            page
          },
          around {
            cursor
            isCurrent
            page
          },
          previous {
            cursor
            isCurrent
            page
          }
        }
        totalCount
        totalPages
      }
    }
    GRAPHQL
  end

  context 'with 0 submissions' do
    let(:results) do
      post('/api/graphql', params: { query: buildQuery }, headers: headers)
      JSON.parse(response.body, object_class: OpenStruct)
    end

    it 'has no pages' do
      expect(results.data.submissions.totalPages).to eq 0
      expect(results.data.submissions.totalCount).to eq 0
    end

    it 'has no pagination cursors' do
      expect(results.data.submissions.pageCursors).to be_nil
    end
  end

  context 'with 1 submission' do
    before { Fabricate(:submission) }

    let(:results) do
      post('/api/graphql', params: { query: buildQuery }, headers: headers)
      JSON.parse(response.body, object_class: OpenStruct)
    end

    it 'has 1 page for 1 submission' do
      expect(results.data.submissions.totalPages).to eq 1
      expect(results.data.submissions.totalCount).to eq 1
    end

    it 'has no pagination cursors' do
      expect(results.data.submissions.pageCursors).to be_nil
    end
  end

  context 'with 20 submissions and 10 submissions per page' do
    before { 20.times.each { |i| Fabricate(:submission, id: i) } }

    let(:results) do
      post('/api/graphql', params: { query: buildQuery }, headers: headers)
      JSON.parse(response.body, object_class: OpenStruct)
    end

    it 'has 2 pages for 20 total submissions' do
      expect(results.data.submissions.totalPages).to eq 2
      expect(results.data.submissions.totalCount).to eq 20
    end

    it 'has 2 around pages' do
      page_cursors = results.data.submissions.pageCursors
      expect(page_cursors.first).to be_nil
      expect(page_cursors.last).to be_nil
      expect(page_cursors.previous).to be_nil
      expect(page_cursors.around.count).to eq 2
      expect(page_cursors.around[0].isCurrent).to be true
      expect(page_cursors.around[0].cursor).to_not eq page_cursors.around[1]
                                                        .cursor
      expect(page_cursors.around[0].cursor).to match(/^\D*$/)
      expect(page_cursors.around[0].page).to eq 1
      expect(page_cursors.around[1].isCurrent).to be false
      expect(page_cursors.around[1].page).to eq 2
    end
  end

  context 'with 100 submissions and 10 submissions per page' do
    before { 100.times.each { |i| Fabricate(:submission, id: i) } }

    let(:page_one) do
      post('/api/graphql', params: { query: buildQuery }, headers: headers)
      JSON.parse(response.body, object_class: OpenStruct)
    end

    it 'has 4 around pages and a last page on page 1' do
      page_cursors = page_one.data.submissions.pageCursors
      expect(page_cursors.first).to be_nil
      expect(page_cursors.last.page).to eq 10
      expect(page_cursors.previous).to be_nil
      expect(page_cursors.around.count).to eq 4
      expect(page_cursors.around.first.isCurrent).to be true
      expect(page_cursors.around.first.page).to eq 1
      expect(page_cursors.around.last.isCurrent).to be false
      expect(page_cursors.around.last.page).to eq 4
    end

    context 'on page 3' do
      let(:page_three) do
        page_three_cursor =
          page_one.data.submissions.pageCursors.around.select do |c|
            c.page == 3
          end.first
            .cursor
        query_inputs = "first: 10, after: \"#{page_three_cursor}\""
        post(
          '/api/graphql',
          params: { query: buildQuery(query_inputs) }, headers: headers
        )
        JSON.parse(response.body, object_class: OpenStruct)
      end

      it 'has 4 around pages and a last page' do
        page_cursors = page_three.data.submissions.pageCursors
        expect(page_cursors.first).to be_nil
        expect(page_cursors.last.page).to eq 10
        expect(page_cursors.previous.page).to eq 2
        expect(page_cursors.around.count).to eq 4
        expect(page_cursors.around.first.isCurrent).to be false
        expect(page_cursors.around.first.page).to eq 1
        expect(page_cursors.around.last.isCurrent).to be false
        expect(page_cursors.around.last.page).to eq 4
      end
    end

    context 'on page 5' do
      let(:page_five) do
        current_page = page_one
        (4..5).each do |next_page_number|
          next_page_cursor =
            current_page.data.submissions.pageCursors.around.select do |c|
              c.page == next_page_number
            end.first
              .cursor
          query_inputs = "first: 10, after: \"#{next_page_cursor}\""
          post(
            '/api/graphql',
            params: { query: buildQuery(query_inputs) }, headers: headers
          )
          current_page = JSON.parse(response.body, object_class: OpenStruct)
        end
        current_page
      end

      it 'has 3 around pages and both first and last page' do
        page_cursors = page_five.data.submissions.pageCursors
        expect(page_cursors.first.page).to eq 1
        expect(page_cursors.last.page).to eq 10
        expect(page_cursors.previous.page).to eq 4
        expect(page_cursors.around.count).to eq 3
        expect(page_cursors.around.first.isCurrent).to be false
        expect(page_cursors.around.first.page).to eq 4
        expect(page_cursors.around[1].isCurrent).to be true
        expect(page_cursors.around[1].page).to eq 5
        expect(page_cursors.around.last.isCurrent).to be false
        expect(page_cursors.around.last.page).to eq 6
      end
    end

    context 'on page 8' do
      let(:page_eight) do
        current_page = page_one
        (4..8).each do |next_page_number|
          next_page_cursor =
            current_page.data.submissions.pageCursors.around.select do |c|
              c.page == next_page_number
            end.first
              .cursor
          query_inputs = "first: 10, after: \"#{next_page_cursor}\""
          post(
            '/api/graphql',
            params: { query: buildQuery(query_inputs) }, headers: headers
          )
          current_page = JSON.parse(response.body, object_class: OpenStruct)
        end
        current_page
      end

      it 'has 4 around pages and a first page but no last page' do
        page_cursors = page_eight.data.submissions.pageCursors

        expect(page_cursors.first.page).to eq 1
        expect(page_cursors.last).to be_nil
        expect(page_cursors.previous.page).to eq 7
        expect(page_cursors.around.count).to eq 4
        expect(page_cursors.around.first.isCurrent).to be false
        expect(page_cursors.around.first.page).to eq 7
        expect(page_cursors.around[1].isCurrent).to be true
        expect(page_cursors.around[1].page).to eq 8
        expect(page_cursors.around.last.isCurrent).to be false
        expect(page_cursors.around.last.page).to eq 10
      end
    end
  end
end
