#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'markaby'

if ARGV.size < 2
  $stderr.puts <<-EOF
usage: obscene <title> <year> [<series episode>] [<language>]
   eg: obscene bones 2004 s04e17 english
   EOF
  exit 1
end

(film, year, seep, language) = *ARGV
language ||= 'english'
title = "subscene subtitles - #{film} #{year} #{seep} #{language}"
links = []
agent = Mechanize.new

agent.get('http://subscene.com/filmsearch.aspx?q=' + film) do |page|
  agent.click(page.link_with(:text => %r{#{year}}i)).links.each do |link|
    text = link.text.strip
    next unless text.length > 0
    next unless text =~ %r{#{language}}i
    next if text =~ /blu-?ray/i
    next unless text =~ %r{#{seep}}i if seep != ''
    links << ["http://subscene.com#{link.href}", link.text.sub(/^\s*#{language}\s*/i, '')]
  end
end

mab = Markaby::Builder.new
mab.html do
  head do
    title title
    style :type => "text/css" do
      %[
        body {
          font: 11px/120% Verdana, sans-serif;
          background: #384310;
          color: white;
          }
        h2 {
          line-height: 2em;
          background: #596B00;
        }
        ul {
          background: #232609;
        }
        a:link {
        color: white;
        }
        a:hover {
        color: yellow;
        }
      ]
    end
  end
  body do
    h2 title
    ul do
      links.sort.each do |link|
        li { a link[1], :href => link[0] }
      end
    end
  end
end
File.open(title.gsub(/\s/, '_') + '.html', 'w') do |f|
  f.puts mab.to_s
end
