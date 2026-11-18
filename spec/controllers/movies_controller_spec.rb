require 'rails_helper'

describe MoviesController, type: :controller do
  describe 'searching TMDb' do
    before do
      @fake_results = [double('movie1'), double('movie2')]
      @search = { title: 'hardware', release_year: '', language: 'en' }
    end

    it 'calls the model method that performs TMDb search' do
      expect(Movie).to receive(:find_in_tmdb).with(@search).
        and_return(@fake_results)
      get :search_tmdb, params: @search
    end

    describe 'after valid search' do
      before do
        allow(Movie).to receive(:find_in_tmdb).and_return(@fake_results)
        get :search_tmdb, params: @search
      end

      it 'selects the Search Results template for rendering' do
        expect(response).to render_template('search_tmdb')
      end

      it 'makes the TMDb search results available to that template' do
        expect(assigns(:movies)).to eq(@fake_results)
      end
    end

    it 'does not search when the page is first opened' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb
      expect(flash[:danger]).to be_nil
    end

    it 'shows an error when the title is missing' do
      expect(Movie).not_to receive(:find_in_tmdb)
      get :search_tmdb, params: { title: '', release_year: '2000', language: 'all' }
      expect(flash[:danger]).to eq('Please fill in all required fields!')
    end

    it 'shows a message when no movies are found' do
      allow(Movie).to receive(:find_in_tmdb).and_return([])
      get :search_tmdb, params: @search
      expect(flash[:danger]).to eq('No movies found with given parameters!')
    end
  end

  describe 'adding a movie' do
    before do
      @movie = { title: 'Manhunter', release_date: '1986-08-15', description: 'A former FBI profiler...', rating: 'R' }
    end

    it 'saves the movie to the database' do
      post :add_movie, params: @movie
      expect(Movie.find_by(title: 'Manhunter')).not_to be_nil
    end

    it 'redirects to the search page with a success message' do
      post :add_movie, params: @movie
      expect(response).to redirect_to(search_tmdb_path)
      expect(flash[:success]).to eq('Manhunter was successfully added to RottenPotatoes.')
    end
  end
end
