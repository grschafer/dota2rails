module MatchesHelper
  def sec_to_hms(x)
    #Time.at(x).utc.strftime('%H:%M:%S')
    h = (x/3600 == 0) ? "" : "#{x/3600}:"
    m = (x/60 == 0) ? "" : "#{x/60}:"
    "#{h}#{m}#{x%60}"
  end

  # TODO: refinement of fixnum?
  def unix_to_rfc822(timestamp)
    DateTime.strptime(timestamp.to_s, '%s').to_formatted_s(:rfc822)
  end
end
