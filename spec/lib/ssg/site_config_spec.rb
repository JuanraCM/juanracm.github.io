# frozen_string_literal: true

require 'spec_helper'

describe SSG::SiteConfig do
  describe '.update' do
    let(:pages) do
      {
        '/blog/first-post' => {
          config: {
            layout: 'post',
            title: 'First Post',
            date: '2024-01-01',
            author: 'John Doe'
          }
        },
        '/blog/second-post' => {
          config: {
            layout: 'post',
            title: 'Second Post',
            date: '2024-01-02'
          }
        },
        '/about' => {
          config: {
            layout: 'page',
            title: 'About'
          }
        }
      }
    end

    before do
      described_class.instance_variable_set(:@posts, nil)
      described_class.update(pages)
    end

    it 'extracts posts from pages with post layout', :aggregate_failures do
      expect(described_class.posts).to be_an(Array)
      expect(described_class.posts.size).to eq(2)
    end

    it 'includes all metadata from post pages', :aggregate_failures do
      first_post = described_class.posts.first
      expect(first_post[:title]).to eq('Second Post')
      expect(first_post[:date]).to eq('2024-01-02')
      expect(first_post[:layout]).to eq('post')
    end

    it 'sorts posts in descending order by date (newest first)' do
      dates = described_class.posts.map { |post| post[:date] }
      expect(dates).to eq(%w[2024-01-02 2024-01-01])
    end

    it 'adds URL with .html extension to each post' do
      urls = described_class.posts.map { |post| post[:url] }
      expect(urls).to contain_exactly('/blog/first-post.html', '/blog/second-post.html')
    end

    it 'excludes pages that are not posts' do
      post_titles = described_class.posts.map { |post| post[:title] }
      expect(post_titles).not_to include('About')
    end
  end
end
