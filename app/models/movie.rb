class Movie < ApplicationRecord
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search, api_key = ENV['TMDB_API_KEY'])
    url = "https://api.themoviedb.org/3/search/movie?api_key=#{api_key}&query=#{CGI.escape(search[:title].to_s)}"
    if search[:release_year].present?
      url += "&year=#{search[:release_year]}"
    end
    if search[:language].present? && search[:language] != 'all'
      url += "&language=#{search[:language]}"
    end

    response = Faraday.get(url)
    if response.status != 200
      return []
    end

    movies = []
    JSON.parse(response.body)['results'].each do |result|
      movies << Movie.new(title: result['title'], release_date: result['release_date'],
                          description: result['overview'], rating: 'R')
    end
    movies
  end
end
