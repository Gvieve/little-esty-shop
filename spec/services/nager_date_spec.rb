require 'rails_helper'

RSpec.describe NagerDateService do
  it 'exists' do
    nagerservice = NagerDateService.new

    expect(nagerservice).to be_a(NagerDateService)
  end

  it "can retrieve the information for next three US public holidays" do
    VCR.use_cassette("NagerPulbicHolidays") do
      holidays = Holidays.new
      public_holidays = holidays.next_3_public_holidays

      expect(public_holidays.count).to eq(3)
      expect(public_holidays.first[:localName]).to eq("Memorial Day")
      expect(public_holidays.first[:date]).to eq("2021-05-31")
      expect(public_holidays[1][:localName]).to eq("Independence Day")
      expect(public_holidays[1][:date]).to eq("2021-07-05")
      expect(public_holidays[2][:localName]).to eq("Labor Day")
      expect(public_holidays[2][:date]).to eq("2021-09-06")
    end
  end
end
