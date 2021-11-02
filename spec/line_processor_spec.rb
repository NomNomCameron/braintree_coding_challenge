require 'spec_helper'
require_relative('../line_processor.rb')

describe LineProcessor do
  let(:lines) { File.open("#{File.dirname(__FILE__) + "/../input.txt"}").each_line.to_a }
  let(:lp) { described_class.new(lines) }

  before do
    lp.call()
  end

  it "should process results as expected" do
    results = lp.instance_variable_get(:@results)
    expect(results.length).to eq(3)
    expect(results[0]).to eq("Lisa: $-93.00")
    expect(results[1]).to eq("Quincy: error")
    expect(results[2]).to eq("Tom: $500.00")
  end

  it "should validate card numbers basd on Luhn 10" do
    valid = lp.credit_card_valid?("5454545454545454")
    invalid = lp.credit_card_valid?("1234567890123456")

    expect(valid).to eq(true)
    expect(invalid).to eq(false)
  end
end
