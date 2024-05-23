# frozen_string_literal: true

require_relative "config/application"
require "graphql/rake_task"
require "sneakers/tasks"

Rails.application.load_tasks

GraphQL::RakeTask.new(schema_name: "ConvectionSchema", idl_outfile: "_schema.graphql")

if Rails.env.development? || Rails.env.test?
  desc "prints out the schema file"
  task print_schema: :environment do
    require "graphql/schema/printer"
    puts GraphQL::Schema::Printer.new(ConvectionSchema).print_schema
  end

  desc "check for schema drift"
  task schema_check: :environment do
    system "./bin/schema_check"
    abort "schema-check failed" unless $CHILD_STATUS.exitstatus.zero?
  end

  require "standard/rake"
  Rake::Task[:default].clear
  task default: %i[schema_check standard spec]
end
