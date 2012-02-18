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
    links << ["http://subscene.com#{link.href}", link.text]
  end
end

mab = Markaby::Builder.new
mab.html do
  head do
    title title
  end
  body do
    h2 title
    ul do
      links.each do |link|
        li { a link[1], :href => link[0] }
      end
    end
  end
end
File.open(title.gsub(/\s/, '_') + '.html', 'w') do |f|
  f.puts mab.to_s
end
