# frozen_string_literal: true

require_relative 'config/application'

Rails.application.load_tasks

if Rails.env.development? || Rails.env.test?
  require 'rubocop/rake_task'
  desc 'Run RuboCop'
  RuboCop::RakeTask.new(:rubocop)

  task 'print_schema' => :environment do
    require 'graphql/schema/printer'
    puts GraphQL::Schema::Printer.new(RootSchema).print_schema
  end

  Rake::Task[:default].clear
  task default: [:rubocop, :spec]
end
