module PackagesHelper
  def date_format( date )
    date ? date.strftime("%d/%m/%Y %H:%M:%S") : "---"
  end

  def completed?( bool )
    bool ? "images/accept.png" : "images/clock.png"
  end
end
