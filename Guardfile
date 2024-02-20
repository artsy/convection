# frozen_string_literal: true

group :livereload do
  guard "livereload", port: "5003", grace_period: 0.5 do
    watch(%r{app/assets/.+})
    watch(%r{app/controllers/.+})
    watch(%r{app/helpers/.+})
    watch(%r{app/views/.+})
  end
end

group :rspec do
  guard :rspec, cmd: "bundle exec rspec" do
    watch("spec/spec_helper.rb")                        { "spec" }
    watch("app/controllers/application_controller.rb")  { "spec/controllers" }
    watch(%r{^spec/.+_spec\.rb$})
    watch(%r{^app/(.+)\.rb$})                           { |m| "spec/#{m[1]}_spec.rb" }
    watch(%r{^app/(.*)(\.erb|\.haml|\.slim)$})          { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
    watch(%r{^lib/(.+)\.rb$})                           { |m| "spec/lib/#{m[1]}_spec.rb" }
    watch(%r{^app/controllers/(.+)_(controller)\.rb$})  { |m| ["spec/#{m[2]}s/#{m[1]}_#{m[2]}_spec.rb", "spec/acceptance/#{m[1]}_spec.rb"] }
  end
end
