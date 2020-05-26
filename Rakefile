# frozen_string_literal: true

require_relative 'config/application'
require 'graphql/rake_task'

Rails.application.load_tasks

GraphQL::RakeTask.new(schema_name: 'ConvectionSchema', idl_outfile: '_schema.graphql')

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  desc 'prints out the schema file'
  task print_schema: :environment do
    require 'graphql/schema/printer'
    puts GraphQL::Schema::Printer.new(ConvectionSchema).print_schema
  end

  desc 'run prettier check'
  task prettier_check: :environment do
    system 'yarn run prettier-check'
    abort 'prettier-check failed' unless $CHILD_STATUS.exitstatus.zero?
  end

  desc 'check for schema drift'
  task schema_check: :environment do
    system './bin/schema_check'
    abort 'schema-check failed' unless $CHILD_STATUS.exitstatus.zero?
  end

  Rake::Task[:default].clear
  task default: %i[prettier_check schema_check rubocop spec]
end
