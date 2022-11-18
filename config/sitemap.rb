require 'rubygems'
require 'sitemap_generator'

SitemapGenerator::Sitemap.default_host = 'https://camino2.herokuapp.com'
SitemapGenerator::Sitemap.compress = false
SitemapGenerator::Sitemap.include_root = false

SitemapGenerator::Sitemap.create do
  add '/users/sign_in'
  add '/about', :priority => 0.9
end