require 'spec_helper'
require 'rails_helper'

describe Movie do
  describe 'searching TMDB by keyword' do
    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).and_call_original
      Movie.find_in_tmdb({ title: 'Olympics', release_year: '2000', language: 'en' })
    end

    it 'calls TMDb with valid API key' do
      url = 'https://api.themoviedb.org/3/search/movie?api_key=test_key&query=hacker&language=en'
      expect(Faraday).to receive(:get).with(url).and_call_original
      Movie.find_in_tmdb({ title: 'hacker', language: 'en' }, 'test_key')
    end

    it 'leaves out year and language when they are not given' do
      url = 'https://api.themoviedb.org/3/search/movie?api_key=test_key&query=hacker'
      expect(Faraday).to receive(:get).with(url).and_call_original
      Movie.find_in_tmdb({ title: 'hacker', release_year: '', language: 'all' }, 'test_key')
    end

    it 'returns movies that are not saved' do
      movies = Movie.find_in_tmdb({ title: 'Olympics', release_year: '2000' })
      expect(movies.length).to eq(2)
      expect(movies[0].title).to eq('Sydney 2000 Olympics Opening Ceremony')
      expect(movies[0].new_record?).to be true
    end

    it 'gives every movie an R rating' do
      movies = Movie.find_in_tmdb({ title: 'Olympics' })
      movies.each do |movie|
        expect(movie.rating).to eq('R')
      end
    end

    it 'returns an empty list when no movies are found' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 200, body: JSON.generate({ page: 1, results: [] }))
      expect(Movie.find_in_tmdb({ title: 'zzzz' })).to eq([])
    end

    it 'returns an empty list when the API key is invalid' do
      stub_request(:get, /api.themoviedb.org/).
        to_return(status: 401, body: JSON.generate({ success: false }))
      expect(Movie.find_in_tmdb({ title: 'hacker' }, 'bad_key')).to eq([])
    end
  end
end
