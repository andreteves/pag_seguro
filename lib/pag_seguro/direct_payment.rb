module PagSeguro
  class DirectPayment
    include ActiveModel::Validations
    extend PagSeguro::ConvertFieldToDigit

    ENVIRONMENT = Rails.env.production? ? "" : "sandbox."
    PAYMENT_URL = "https://ws.#{ENVIRONMENT}pagseguro.uol.com.br/v2/transactions"

    attr_accessor :id, :email, :token, :items, :sender, :shipping, :billing_address,
                  :credit_card, :bank, :extra_amount, :method, :response
    alias :reference  :id
    alias :reference= :id=

    attr_reader_as_digit :extra_amount

    validates_presence_of :email, :token
    validates :extra_amount, pagseguro_decimal: true
    validate :valid_items

    def initialize(email = nil, token = nil, options = {})
      @email = email unless email.nil?
      @token = token unless token.nil?
      @sender = options[:sender] || Sender.new
      @shipping = options[:shipping]
      @billing_address = options[:billing_address]
      @credit_card = options[:credit_card] || nil
      @bank = options[:bank] || nil
      @items = options[:items] || []
      @extra_amount = options[:extra_amount]
      @id = options[:id] || options[:reference]
      @method = options[:method]
    end

    def self.checkout_payment_url(code)
      "https://#{ENVIRONMENT}pagseguro.uol.com.br/v2/checkout/payment.html?code=#{code}"
    end

    def payment_xml
      xml_content = File.open( File.dirname(__FILE__) + "/payment.xml.haml" ).read
      haml_engine = Haml::Engine.new(xml_content)

      haml_engine.render Object.new,
                         items: @items,
                         payment: self,
                         sender: @sender,
                         shipping: @shipping,
                         billing_address: @billing_address,
                         credit_card: @credit_card,
                         bank: @bank
    end

    def checkout_payment_url
      self.class.checkout_payment_url(code)
    end

    def code
      response || parse_payment_response
      parse_code
    end

    def date
      response || parse_payment_response
      parse_date
    end
    
    def payment_link
      response || parse_payment_response
      parse_payment_link
    end

    def reset!
      @response = nil
    end

    protected

      def valid_items
        if items.blank? || !items.all?(&:valid?)
          errors.add(:items, " must be all valid")
        end
      end

      def send_payment
        params = { email: @email, token: @token }
        RestClient.post(PAYMENT_URL, payment_xml, params: params, content_type: "application/xml"){|resp, request, result| resp }
      end

      def parse_payment_response
        res = send_payment
        raise Errors::Unauthorized if res.code == 401
        raise Errors::InvalidData.new(res.body) if res.code == 400
        raise Errors::UnknownError.new(res) if res.code != 200
        @response = res.body
      end

      def parse_date
        DateTime.iso8601(Nokogiri::XML(response.body).css("transaction date").first.content)
      end

      def parse_code
        Nokogiri::XML(response.body).css("transaction code").first.content
      end
      
      def parse_payment_link
        payment_link = Nokogiri::XML(response.body).css("transaction paymentLink").first
        payment_link.content if payment_link
      end
  end
end
