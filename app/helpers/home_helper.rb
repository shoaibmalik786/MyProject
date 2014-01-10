module HomeHelper
  def alert_url(alert)
    item = (alert.item.nil? ? alert.trade.item : alert.item)

    if alert.is_new
      return "/mark_alert_read_and_redirect?id=" + alert.id.to_s + "&redirect_url=" + URI.encode(item_path(item))
    else
      return item_path(item)
    end
  end
end
