# frozen_string_literal: true

require 'yaml'

module SSG
  module SiteConfig
    SITE_CONFIG_FILE = File.join(ROOT_DIR, 'site.yml').freeze

    class << self
      attr_reader :posts, :author, :bio, :resume_filename

      def update(pages)
        load_site_config
        load_posts(pages)
      end

      private

      def load_site_config
        config = YAML.load_file(SITE_CONFIG_FILE, symbolize_names: true)

        @author = config[:author]
        @bio = config[:bio]
        @resume_filename = config[:resume_filename]
      end

      def load_posts(pages)
        @posts = []

        pages.each do |path, meta|
          page_config = meta[:config]
          next unless page_config[:layout] == 'post'

          @posts << page_config.merge(url: "#{path}.html")
        end

        @posts.sort_by! { |post| post[:date] }.reverse!
      end
    end
  end
end
