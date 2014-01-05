require 'json'

class MatchesController < ApplicationController
  before_action :set_match, except: [:index]

  @@matchurls_regex = Regexp.new('http.*?\.dem\.bz2')

  # GET /matches
  # GET /matches.json
  def index
    @matches = db.find().to_a
  end

  def mymatches
    # TODO: mymatches filtered by matches this user's steamid is in
    #       OR matches requested by this user (might upload a replay they're not in)
    @matches = db.find({'duration' => {'$lt' => 2000}}).to_a
    @mymatches = true
    render :index
  end

  # GET /matches/1
  # GET /matches/1.json
  def show
    # TODO: authentication
    gon.match = @match
    respond_to do |format|
      format.html
      format.json { render json: @match }
    end
  end

  def matchurls
    # TODO: require authentication
    # TODO: rate limit this per-session?
    # TODO: check if in matches db (match already processed, add this user to access list if not public?)
    url = URI.parse("http://localhost:3100/tools/matchurls?matchid=#{request.params['match_id']}")
    res = Net::HTTP::get(url)
    match = @@matchurls_regex.match(res)
    if match.nil?
      render json: {'status' => 'failure'}
    else
      render json: {'status' => 'success'}
    end
  end

  def request_match
    puts request
    render json: {'status' => 'success'}
  end

  # POST /matches
  # for newly-uploaded replay
  def create
    # TODO: add validation to only allow uploading .dem files (would be in JS)
    # TODO: kick off celery task
    replay_url = request.params['replay_url']
    puts "REPLAY UPLOADED TO #{replay_url}"
    # TODO: fix mongo database/collection stuff
    db.db['useruploads'].insert({'url' => replay_url,
                                 'requesting_user' => session[:current_user][:uid],
                                 'notif_method' => 'email',
                                 'notif_address' => 'a@b.com'})
    render json: {'status' => "success"}
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
