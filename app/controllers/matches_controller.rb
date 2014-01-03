require 'json'

class MatchesController < ApplicationController
  before_action :set_match, except: [:index]

  # GET /matches
  # GET /matches.json
  def index
    @matches = db.find().to_a
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    gon.match = @match
    respond_to do |format|
      format.html
      format.json { render json: @match }
    end
  end

  # POST /matches
  # for newly-uploaded replay
  def create
    # TODO: add validation to only allow uploading .dem files (would be in JS)
    # TODO: kick off celery task
    replay_url = request.params['replay_url']
    puts "REPLAY UPLOADED TO #{replay_url}"
    # TODO: fix mongo database/collection stuff
    db.db['useruploads'].insert({'url' => replay_url, 'notif_method' => 'email', 'notif_address' => 'a@b.com'})
    render text: "success"
  end


  private

    # Use callbacks to share common setup or constraints between actions.
    # TODO: CACHE MATCH
    def set_match
      @match = db.find_one({'match_id' => params[:id].to_i})

      #json = nil
      #open("app/assets/json/test_match.js") do |f|
      #  json = f.gets
      #end
      #json = JSON.parse(json)
      #@match ||= json
    end
end
