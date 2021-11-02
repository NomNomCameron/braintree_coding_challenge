class LineProcessor
  def initialize(lines)
    @lines = lines
    @customers = []
    @charges = []
    @credits = []
    @results = []
  end

  def call
    @lines.each do |line|
      process_line(line)
    end

    process_results
  end

  def process_line(line)
    if line.match(/^Add/)
      name = name_from_line(line)
      cc_number = line.match(/[0-9]{1,19}\s/)[0].gsub(" ", "")
      limit = dollar_amount_from_line(line)

      @customers << { name: name, cc_number: cc_number, limit: limit, balance: 0 }
    elsif line.match(/^Charge/)
      name = name_from_line(line)
      record = @customers.select { |c| c[:name] == name }[0]
      if credit_card_valid?(record[:cc_number])
        @charges << { customer_name: name, amount: dollar_amount_from_line(line) }
      end
    elsif line.match(/^Credit/)
      name = name_from_line(line)
      record = @customers.select { |c| c[:name] == name }[0]
      if credit_card_valid?(record[:cc_number])
        @credits << { customer_name: name, amount: dollar_amount_from_line(line) }
      end
    end
  end

  def process_results
    @charges.each do |charge|
      customer_record = customer_record_from_name(charge[:customer_name])
      if charge[:amount].to_f + customer_record[:balance].to_f <= customer_record[:limit].to_f && credit_card_valid?(customer_record[:cc_number])
        customer_record[:balance] = customer_record[:balance].to_f + charge[:amount].to_f
      end
    end

    @credits.each do |credit|
      customer_record = customer_record_from_name(credit[:customer_name])
      if credit_card_valid?(customer_record[:cc_number])
        customer_record[:balance] = customer_record[:balance].to_f - credit[:amount].to_f
      end
    end

    strings = []
    @customers.sort_by { |c| c[:name] }.each do |c|
      string = "#{c[:name]}: "
      if credit_card_valid?(c[:cc_number])
        string += "$#{sprintf('%.2f', c[:balance])}"
      else
        string += "error"
      end

      strings << string
    end

    @results = strings
    if $0 == __FILE__
      strings.each { |s| puts s + "\n" }
    end
  end

  def customer_record_from_name(name)
    @customers.select { |c| c[:name] == name }[0]
  end

  def total_customer_charges(name)
    @charges.select { |c| c[:name] == name }.sum { |c| c[:amount] }
  end

  def name_from_line(line)
    line.match(/\s([A-Z][a-z]*)/)[0].gsub(" ", "")
  end

  def dollar_amount_from_line(line)
    line.match(/\$([0-9]?)*/)[0].gsub("$", "")
  end

  def credit_card_valid?(number)
    digits = number.chars.map(&:to_i)
    check = digits.pop

    sum = digits.reverse.each_slice(2).flat_map do |x, y|
      [(x * 2).divmod(10), y || 0]
    end.flatten.inject(:+)

    check.zero? ? sum % 10 == 0 : (10 - sum % 10) == check
  end
end

lines = ARGF.to_a
if ARGV.length > 0
  # path to file passed in, manually open and read to process
  path = ARGV[0]
  file = File.open(path)
  lines = file.each_line.to_a
end
ARGF.close

LineProcessor.new(lines).call
