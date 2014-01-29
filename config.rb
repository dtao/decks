helpers do
  def decks
    sitemap.resources.select do |resource|
      resource.path.start_with?('decks/')
    end
  end

  def raw_source(resource)
    content = File.read(resource.source_file)

    # Skip the metadata in the beginning
    content.lines[4..-1].join()
  end
end

set :css_dir, 'stylesheets'

set :js_dir, 'javascripts'

set :images_dir, 'images'

# This is necessary since the site is hosted at danieltao.com/decks
set :relative_links, true

# Build-specific configuration
configure :build do
  # For example, change the Compass output style for deployment
  activate :minify_css

  # Minify Javascript on build
  activate :minify_javascript

  # Use relative URLs
  activate :relative_assets
end


Dir['source/decks/*.markdown'].each do |file|
  file = File.basename(file, '.markdown')
  proxy "/#{file}.html", "decks/#{file}.html", :layout => 'deck'
  proxy "/raw/#{file}.markdown", "decks/#{file}.html", :layout => 'raw'
end
