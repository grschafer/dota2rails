require 'json'

class MatchesController < ApplicationController
  before_action :authenticated, only: [:mymatches, :matchurls, :request_match, :request_notification, :create]
  before_action :set_match, only: [:show]
  before_action :match_authorized, only: [:show]

  @@matchurls_regex = Regexp.new('http.*?\.dem\.bz2')
  @@url_matchid_regex = Regexp.new('.*?(\d+.dem)$')

  # TODO: clean up make_filter_dropdowns and @league_hash
  #       not DRY and extra unnecessary work being done in filter method

  # GET /matches
  # GET /matches.json
  def index
    @matches = db.find({'requester' => 'public'}).to_a
    make_filter_dropdowns(@matches)
    @league_hash = Hash[@leagues.map { |x| x.values }]
    @league_hash.default = "None"
  end

  def mymatches
    # shows matches current user played in or requested
    @matches = db.find({'$or' => [{'requester' => session[:user][:uid]},
                                  {'players.account_id' => session[:user][:uid]}]}).to_a
    make_filter_dropdowns(@matches)
    @league_hash = Hash[@leagues.map { |x| x.values }]
    @league_hash.default = "None"

    @queued_matches = db.db['useruploads'].find({'requesting_user' => session[:user][:uid]},
                              {:fields => {'_id' => 0, 'match_id' => 1, 'url' => 1}}).to_a
    @queued_matches.map! do |m|
      if m.key?('url')
        @@url_matchid_regex.match(m['url']).captures[0]
      else
        m['match_id']
      end
    end
  end

  def filter
    hero = params[:hero]
    player = params[:player]
    league = params[:league]
    team = params[:team]

    criteria = {}
    criteria['players.hero_name'] = hero if hero != 'all'
    criteria['players.player_name'] = {'$regex' => "#{player}", '$options' => 'i'} if !player.empty?
    criteria['leagueid'] = league.to_i if league != 'all'
    criteria['$or'] = [{'radiant_name' => team}, {'dire_name' => team}] if team != 'all'
    puts hero, player, league, team
    puts "criteria: #{criteria}"
    @matches = db.find(criteria).to_a
    puts "matches: #{@matches}"

    make_filter_dropdowns(@matches)
    @league_hash = Hash[@leagues.map { |x| x.values }]
    @league_hash.default = "None"
    render :partial => 'matchlist'
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

  def matchurls
    # TODO: require authentication (confirm user_id in post matches session? make POST synchronous?)
    # TODO: rate limit this per-session?  # https://github.com/kickstarter/rack-attack
    url = URI.parse("http://localhost:3100/tools/matchurls?matchid=#{params['match_id']}")
    res = Net::HTTP::get(url)
    match = @@matchurls_regex.match(res)
    if match.nil?
      render json: {'status' => 'failure', 'msg' => 'Match is unavailable -- it might be invalid/private/expired or Dota 2 network is down'}
    else
      render json: {'status' => 'success', 'msg' => 'Match is available!'}
    end
  end

  def request_match
    # TODO: rate limit this per-session?  # https://github.com/kickstarter/rack-attack
    # prevent duplicate match requests
    exists = db.find({'match_id' => params['match_id']})
    if exists and exists.count > 0
      render json: {'status' => 'failure', 'msg' => 'Match already exists in database'}
      return
    end

    # check valve api for that match to make sure requesting_user was in the match
    url = URI.parse("http://api.steampowered.com/IDOTA2Match_570/GetMatchDetails/v1?key=#{ENV['STEAM_WEB_API_KEY']}&match_id=#{params['match_id']}")
    res = Net::HTTP::get(url)
    match_details = JSON.load(res)['result']
    if match_details.key?('error') || !match_details.key?('players')
      render json: {'status' => 'failure', 'msg' => 'Error getting match details'}
      return
    end
    if !match_details['players'].any? { |p| p['account_id'] == session[:user][:uid] }
      render json: {'status' => 'failure', 'msg' => "You requested a match that you didn't play in"}
      return
    end

    db.db['useruploads'].insert({'match_id' => params['match_id'],
                                 'notif_key' => params['notif_key'],
                                 'requesting_user' => session[:user][:uid]})
    render json: {'status' => 'success', 'msg' => 'Match requested successfully'}
  end

  def request_notification
    cur_user = session[:user][:uid]
    notif_key = params['notif_key']
    notif_method = params['notif_method']
    notif_address = params['notif_address']
    db.db['useruploads'].update({'notif_key' => notif_key, 'requesting_user' => cur_user},
                                {'$set' => {'notif_method' => notif_method,
                                            'notif_address' => notif_address}})
    render json: {'status' => 'success', 'msg' => 'You should get a message shortly!'}
  end

  # POST /matches
  # for newly-uploaded replay
  def create
    # TODO: add validation to only allow uploading .dem files (would be in JS)
    # TODO: kick off celery task (currently runs periodically via celery-beat)
    # TODO: prevent duplicate uploads

    replay_url = params['replay_url']
    puts "REPLAY UPLOADED TO #{replay_url}"
    # TODO: fix mongo database/collection stuff
    db.db['useruploads'].insert({'url' => replay_url,
                                 'notif_key' => params['notif_key'],
                                 'requesting_user' => session[:user][:uid]})
    render json: {'status' => "success"}
  end


  private

    # TODO: cache for matches?

    def set_match
      @match = db.find_one({'match_id' => params[:id].to_i})
    end
    def authenticated
      if !session.key? :user
        render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: "application"
      end
    end
    def match_authorized
      # user must be in @match['players'] unless they uploaded replay file
      #   don't want to let people request any replay and see it (anonymous players)
      # this is enforced when a match is requested

      # if match was requested with ?h=<_id> then it's a shared link,
      # for sending to steam friends
      if params[:h] == @match['_id'].to_s
        # TODO: check that the logged-in user is friend of that match's requester
      else
        unless @match['requester'] == 'public' ||
           (session.key?(:user) &&
             (@match['requester'] == session[:user][:uid] ||
              @match['players'].any? { |p| p['account_id'] == session[:user][:uid] }))
          render file: File.join(Rails.root, 'public/403.html'), status: 403, layout: "application"
        end
      end
    end

    # TODO: clean up make_filter_dropdowns and @league_hash
    def make_filter_dropdowns(matches)
      league_ids = matches.uniq { |x| x['leagueid'] }.map { |x| x['leagueid'] }
      leagues = db.db['leagues'].find({'leagueid' => {'$in' => league_ids}},
                              {:fields => {'_id' => 0, 'leagueid' => 1, 'name' => 1}}).to_a
      rteams = matches.uniq { |x| x['radiant_name'] }.map { |x| x['radiant_name'] }
      dteams = matches.uniq { |x| x['dire_name'] }.map { |x| x['dire_name'] }
      teams = rteams + dteams

      @leagues = leagues
      @teams = teams
    end
end
