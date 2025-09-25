# frozen_string_literal: true

require_relative 'config'

require 'listen'

module SSG
  module HotReload
    def self.start
      listener = Listen.to(*target_directories) do |modified, added, removed|
        puts 'Changes detected. Rebuilding site...'

        changed_files = (modified + added + removed).uniq
        puts "Files changed: #{changed_files.join(', ')}"

        SSG::Builder.prepare_output_dir
        SSG::Builder.build

        puts 'Rebuild complete.'
      end

      puts 'Starting file listener...'
      listener.start
    end

    def self.target_directories
      [
        ASSETS_DIR,
        LAYOUTS_DIR,
        PAGES_DIR
      ]
    end

    def self.update_refresh_timestamp
      timestamp_file = File.join(BUILD_DIR, 'refresh.txt')
      File.write(timestamp_file, Time.now.to_s)
    end
  end
end
