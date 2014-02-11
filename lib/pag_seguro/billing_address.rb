module PagSeguro
  class BillingAddress
    include ActiveModel::Validations

    validates :postal_code, numericality: true, length: {is: 8}

    attr_accessor :state, :city, :postal_code, :district,
                  :street, :number, :complement

    def initialize(attributes = {})
      @state = attributes[:state]
      @city = attributes[:city]
      @postal_code = attributes[:postal_code]
      @district = attributes[:district]
      @street = attributes[:street]
      @number = attributes[:number]
      @complement = attributes[:complement]
    end

    def postal_code
      @postal_code if @postal_code.present? && @postal_code.to_s.size == 8
    end

  end
end
