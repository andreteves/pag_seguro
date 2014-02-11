module PagSeguro
  class CreditCard
    include ActiveModel::Validations
    extend PagSeguro::ConvertFieldToDigit
    
    attr_accessor :token, :installment_quantity, :installment_value, :holder_name,
                  :holder_birth_date, :holder_cpf, :holder_area_code, :holder_phone
    attr_reader_as_digit :installment_value
    
    validates :installment_value, pagseguro_decimal: true, presence: true
    validates :installment_quantity, presence: true, numericality: { only_integer: true, greater_than: 0, less_than: 19 }
    validates :token, :holder_name, :holder_birth_date, :holder_cpf, :holder_area_code, :holder_phone, presence: true

    def initialize(options = {})
      @token = options[:token]
      @installment_quantity = options[:installment_quantity]
      @installment_value = options[:installment_value]
      @holder_name = options[:holder_name]
      @holder_birth_date = options[:holder_birth_date]
      @holder_cpf = options[:holder_cpf]
      @holder_area_code = options[:holder_area_code]
      @holder_phone = options[:holder_phone]
    end

    def holder_name
      return nil unless valid_name?
      @holder_name.gsub(/ +/, " ")[0..49]
    end

    def valid_name?
      @holder_name =~ /\S+ +\S+/
    end

    def holder_area_code
      @holder_area_code if @holder_area_code.to_s =~ /\A\d{2}\z/
    end

    def holder_phone
      @holder_phone if @holder_phone.to_s =~/\A\d{8,9}\z/
    end

  end
end
