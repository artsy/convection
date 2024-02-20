# frozen_string_literal: true

require "rails_helper"

describe ApplicationHelper, type: :helper do
  describe "markdown_formatted" do
    it "returns nil if passed a nil" do
      html = helper.markdown_formatted(nil)
      expect(html).to eq nil
    end

    it "returns parsed and rendered HTML" do
      text = "this is a note\r\nit has a line break"
      html = helper.markdown_formatted(text)
      expect(html).to eq "<p>this is a note\nit has a line break</p>\n"
    end
  end
end
