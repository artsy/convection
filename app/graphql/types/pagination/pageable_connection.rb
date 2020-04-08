# frozen_string_literal: true

module Types
  module Pagination
    class PageableConnection < GraphQL::Types::Relay::BaseConnection
      field :page_cursors, Types::Pagination::PageCursorsType, null: true
      field :total_pages, Int, null: true
      field :total_count, Int, null: true

      MAX_CURSOR_COUNT = 5

      def page_cursors
        return if total_pages <= 1

        cursors = {}
        if total_pages > MAX_CURSOR_COUNT && around_page_numbers.exclude?(1)
          cursors[:first] = page_cursor(1)
        end
        cursors[:around] = around_page_numbers.map { |pn| page_cursor(pn) }
        if total_pages > MAX_CURSOR_COUNT &&
             around_page_numbers.exclude?(total_pages)
          cursors[:last] = page_cursor(total_pages)
        end
        cursors[:previous] = page_cursor(current_page - 1) if current_page > 1

        cursors
      end

      def total_pages
        return 0 if object.nodes.size.zero?
        return 1 if nodes_per_page.nil?

        (object.nodes.size.to_f / nodes_per_page).ceil
      end

      def total_count
        object.nodes.size
      end

      private

      def page_cursor(page_num)
        {
          cursor: cursor_for_page(page_num),
          is_current: current_page == page_num,
          page: page_num
        }
      end

      def cursor_for_page(page_num)
        return '' if page_num == 1

        after_cursor = (page_num - 1) * nodes_per_page
        object.encode(after_cursor.to_s)
      end

      def current_page
        nodes_before / nodes_per_page + 1
      end

      def around_page_numbers
        if total_pages <= MAX_CURSOR_COUNT
          (1..total_pages).to_a
        elsif current_page <= 3
          (1..4).to_a
        elsif current_page >= total_pages - 2
          ((total_pages - 3)..total_pages).to_a
        else
          [current_page - 1, current_page, current_page + 1]
        end
      end

      def nodes_before
        node_offset(object.edge_nodes.first) - 1
      end

      def nodes_after
        node_offset(object.edge_nodes.last)
      end

      def node_offset(node)
        # this was previously accomplished by calling a private method: object.send(:offset_from_cursor, object.cursor_from_node(object.edge_nodes.first))
        object.nodes.index(node) + 1
      end

      def nodes_per_page
        object.first || object.last
      end
    end
  end
end
