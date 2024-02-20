# frozen_string_literal: true

require "rails_helper"

module DefaultValueExtensionSpec
  class Query < GraphQL::Schema::Object
    field :name, String, null: false do
      extension(Extensions::DefaultValueExtension, default_value: "Name")
    end

    def name
      @@name_value
    end
  end

  class ConnectionSchema < GraphQL::Schema
    query(Query)
  end

  describe "Extensions::DefaultValueExtension" do
    before(:each) { Query.class_variable_set(:@@name_value, nil) }

    it "changes nil value to default" do
      res = ConnectionSchema.execute("{ name }")

      expect(res["data"]["name"]).to eq "Name"
    end

    it "doesnt use default value if not nil" do
      Query.class_variable_set(:@@name_value, "own name")
      res = ConnectionSchema.execute("{ name }")

      expect(res["data"]["name"]).to eq "own name"
    end
  end
end
