module PagSeguro
  class Bank
    
    BRADESCO = 1
    ITAU = 2
    BANCOSOBRASIL = 3
    BANRISUL = 4
    HSBC = 5
    
    attr_accessor :name

    def initialize(options = {})
      @name = options[:name]
    end

  end
end
