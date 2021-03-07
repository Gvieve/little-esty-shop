class Holidays
  attr_reader :next_3_public_holidays

  def initialize
    @nagerservice = NagerDateService.new
    @next_3_public_holidays = next_public_holidays
  end

  private

  def next_public_holidays
    @nagerservice.get_data[0..2]
  end
end
