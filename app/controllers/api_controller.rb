require 'pry'
require_relative 'controller'
require 'psych'
require 'json'

module Slides
  class ApiController < Controller
    def slides
      slides = []
      Dir[ app.root.join('content').to_s + '/*.yml' ].each do |slide|
        slides << Psych.load(File.read(slide))
      end
      render body: slides.to_json, headers: {
        'Content-Type' => 'application/json'
      }
    end
  end
end
