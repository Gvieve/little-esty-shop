class NagerDateService

  def get_data
    response = Faraday.get("https://date.nager.at/Api/v2/NextPublicHolidays/US")
    data = response.body
    json = JSON.parse(data, symbolize_names: true)
  end
end
