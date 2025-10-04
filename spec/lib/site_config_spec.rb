# frozen_string_literal: true

require 'spec_helper'

require_relative '../../lib/site_config'

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
    end

    it 'extracts posts from pages with post layout', :aggregate_failures do
      described_class.update(pages)

      expect(described_class.posts).to be_an(Array)
      expect(described_class.posts.size).to eq(2)
    end

    it 'includes all metadata from post pages', :aggregate_failures do
      described_class.update(pages)

      first_post = described_class.posts.first
      expect(first_post[:title]).to eq('First Post')
      expect(first_post[:date]).to eq('2024-01-01')
      expect(first_post[:author]).to eq('John Doe')
      expect(first_post[:layout]).to eq('post')
    end

    it 'adds URL with .html extension to each post' do
      described_class.update(pages)

      urls = described_class.posts.map { |post| post[:url] }
      expect(urls).to contain_exactly('/blog/first-post.html', '/blog/second-post.html')
    end

    it 'excludes pages that are not posts' do
      described_class.update(pages)

      post_titles = described_class.posts.map { |post| post[:title] }
      expect(post_titles).not_to include('About')
    end

    it 'handles empty pages hash' do
      described_class.update({})

      expect(described_class.posts).to be_an(Array)
      expect(described_class.posts).to be_empty
    end

    it 'handles pages with no posts', :aggregate_failures do
      non_post_pages = {
        '/about' => {
          config: { layout: 'page', title: 'About' }
        },
        '/contact' => {
          config: { layout: 'page', title: 'Contact' }
        }
      }

      described_class.update(non_post_pages)

      expect(described_class.posts).to be_an(Array)
      expect(described_class.posts).to be_empty
    end

    it 'resets posts on subsequent updates', :aggregate_failures do
      described_class.update(pages)
      initial_count = described_class.posts.size

      new_pages = {
        '/blog/third-post' => {
          config: {
            layout: 'post',
            title: 'Third Post'
          }
        }
      }

      described_class.update(new_pages)

      expect(described_class.posts.size).to eq(1)
      expect(described_class.posts.first[:title]).to eq('Third Post')
    end
  end
end
