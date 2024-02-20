# frozen_string_literal: true

require "rails_helper"

class TestType < GraphQL::Schema::Object
  field :name, String, null: true do
    extension(Extensions::NilableFieldExtension)
  end
end

class TestTypeWithoutExtension < GraphQL::Schema::Object
  field :name, String, null: true
end

module NilableFieldExtensionSpec
  class Query < GraphQL::Schema::Object
    field :test_type, TestType, null: true
    field :test_type_without_extension, TestTypeWithoutExtension, null: true

    def test_type
      @@test_type
    end

    def test_type_without_extension
      @@test_type
    end
  end

  class ConnectionSchema < GraphQL::Schema
    query(Query)
  end

  describe "Extensions::NilableFieldExtension" do
    before(:each) { Query.class_variable_set(:@@test_type, nil) }

    it "returns nil if value to resolve isnt provided" do
      Query.class_variable_set(:@@test_type, OpenStruct.new({}))
      res = ConnectionSchema.execute("{ testType { name } }")

      expect(res["data"]["testType"]["name"]).to eq nil
    end

    it "returns correct value if value to resolve is provided" do
      Query.class_variable_set(:@@test_type, OpenStruct.new({name: "name"}))
      res = ConnectionSchema.execute("{ testType { name } }")

      expect(res["data"]["testType"]["name"]).to eq "name"
    end

    it "raise an error if try to load field that cant be resolved" do
      Query.class_variable_set(:@@test_type, OpenStruct.new({}))

      expect {
        ConnectionSchema.execute("{ testTypeWithoutExtension { name } }")
      }.to raise_error(RuntimeError)
    end
  end
end
