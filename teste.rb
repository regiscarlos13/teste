# frozen_string_literal: true

require 'yaml'

# Nesse teste, procurei usar metodos inteligentes com metaprogramação para serem versáteis e flexíveis,
# permitindo que realizem várias operações com base em argumentos ou contextos diferentes.
# O metodo solucao o mesmo é capaz de receber um array com varios hash e listar todos
# os campos e valores sem a necessidade de especificamos os campos passando simplemente o argumento,
# nesse caso os parametros estão por default no metodo truncar_e_preencher.
# Ex: solucao(args: [argumentos]), por outro lado caso tenha necessidade de formatar os campos poderá
# acrescentar um arquivo yml com as configurações e passar no metodo. Ex: solucao(args: [argumentos], file: arquivo.yaml)

class LoadFile
  attr_reader :formato1, :formato2

  def initialize
    @formato1 = load_yaml('format-1.yaml')
    @formato2 = load_yaml('format-2.yaml')
  end

  def load_yaml(filename)
    YAML.load_file(filename)
  end

  def input
    [
      { name: 'Maria Neusa de Aparecida',
        cpf: '97905796671',
        state: 'Sao Paulo',
        value: '1234' },
      { name: 'Ricardo Fontes',
        cpf: '44010762900',
        state: 'Rio Grande do Sul',
        value: '567' }
    ]
  end
end

class ConvertHashForString < LoadFile
  def call
    puts 'Resposta da questão 01'
    puts
    solucao(args: input)
    puts '*' * 50
    puts 'Resposta da questão 02'
    puts
    solucao(file: formato1, args: input)
    puts
    solucao(file: formato2, args: input)
  end

  private

  def solucao(args:, file: nil)
    puts convert_hash_for_string(args:, file:)
  end

  def convert_hash_for_string(args:, file: nil)
    keys = file&.keys&.map(&:to_sym)
    inputs = keys.nil? ? args : args.map { |x| x.slice(*keys) }
    inputs.map { |key| convert_key_to_string(key, file) }.join("\n")
  end

  def convert_key_to_string(key, file)
    key.map do |key, value|
      params_format(value, key.to_s, file)
    end.join('')
  end

  def params_format(value, key, formato)
    file_format = formato

    if file_format.nil?
      truncar_e_preencher(value)
    else
      file_format_hash = file_format[key]
      return unless file_format_hash

      length  = file_format_hash['length']
      align   = file_format_hash['align']
      padding = file_format_hash['padding']
      truncar_e_preencher(value, length:, align:, padding:)
    end
  end

  def truncar_e_preencher(string, options = {})
    align   = options.fetch(:align, 'left')
    length  = options.fetch(:length, 11)
    padding = options.fetch(:padding, ' ')

    padding = padding.eql?('zeroes') ? '0' : ' '

    truncated_string = string[0...length]

    if align.eql?('left')
      truncated_string.ljust(length, padding)
    else
      truncated_string.rjust(length, padding)
    end
  end
end

class ConvertStringForHash < LoadFile
  define_method :convert_string_for_hash do |string|
    keys = formato1
    result = {}
    position_keys = keys.values.map { |x| x['length'] }.unshift(0)
    position_value = 0
    1..keys.size.times do |position|
      new_string = string.slice(position_value += position_keys[position], keys.values[position]['length'])
      result.store(keys.keys[position].to_sym, new_string.sub(/\A0+/, '').strip)
    end
    result
  end
end

hash_for_string = ConvertHashForString.new
hash_for_string.call

puts '*' * 50
string_for_hash = ConvertStringForHash.new
puts string_for_hash.convert_string_for_hash('97905796671Maria Neusa de00001234')
puts string_for_hash.convert_string_for_hash('44010762900Ricardo Fontes00000567')
