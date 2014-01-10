module MatchesHelper
  def sec_to_hms(s)
    #Time.at(s).utc.strftime('%H:%M:%S')
    s = s.to_i
    mm, ss = s.divmod(60)
    hh, mm = mm.divmod(60)
    if hh > 0
      "#{hh}:#{mm.to_s.rjust(2, '0')}:#{ss.to_s.rjust(2, '0')}"
    else
      "#{mm}:#{ss.to_s.rjust(2, '0')}"
    end
  end

  # TODO: refinement of fixnum?
  def unix_to_date(timestamp)
    DateTime.strptime(timestamp.to_s, '%s').to_s(:db)
  end
end
