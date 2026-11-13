# frozen_string_literal: true

# Billing export (Ruby 4.0).
# Upgrade traps (handled in the Ruby 3.2 -> 4.0 upgrade):
#  - base64, csv and bigdecimal stop being default gems in Ruby 3.4 (bundled gems): add them to the
#    Gemfile and vendor them, or `require` warns/fails under Bundler.
#  - String literals are "chilled" in Ruby 3.4: mutating one (<<) warns, and will raise later.
#    Add `# frozen_string_literal: false`, or use String.new / +"".
#  - Gemfile `ruby "~> 3.2.0"` and .ruby-version 3.2.2 must move with the runtime.
require 'json'
require 'base64'
require 'csv'
require 'bigdecimal'
require 'bigdecimal/util'

Invoice = Struct.new(:id, :amount, :currency, keyword_init: true)

def to_csv(invoices)
  CSV.generate do |csv|
    csv << %w[id amount currency]
    invoices.each { |i| csv << [i.id, i.amount.to_s('F'), i.currency] }
  end
end

def handler(event:, context:)
  rows = (event && event['invoices']) || [{ 'id' => 'inv-1', 'amount' => '19.99', 'currency' => 'usd' }]
  invoices = rows.map do |r|
    Invoice.new(id: r['id'], amount: r['amount'].to_d, currency: r['currency'].upcase)
  end

  label = +'billing-export' # unary plus: mutable copy, literals are frozen
  label << '-' << Time.now.utc.strftime('%Y%m%d')

  total = invoices.sum(BigDecimal('0'), &:amount)
  {
    statusCode: 200,
    body: JSON.generate(
      label: label,
      total: total.to_s('F'),
      csv_base64: Base64.strict_encode64(to_csv(invoices))
    )
  }
end
