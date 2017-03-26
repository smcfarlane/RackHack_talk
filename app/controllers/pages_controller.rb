require 'pry'
require_relative 'controller'

module Slides
  class PagesController < Controller
    def index
      html = File.open('public/index.html', File::RDONLY)
      render body: html, headers: {'Content-Type' => 'text/html'}, status: 200
    end
  end
end
