# frozen_string_literal: true

module HelperMethods
  def fixture_path(*paths)
    File.expand_path(File.join(__dir__, 'fixtures', *paths))
  end
end
