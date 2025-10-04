# frozen_string_literal: true

module SSG
  module SiteConfig
    class << self
      attr_reader :posts, :site_title, :site_description

      def update(pages)
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
