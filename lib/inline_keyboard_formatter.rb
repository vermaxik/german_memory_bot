class InlineKeyboardFormatter
  attr_reader :array

  def initialize(array)
    @array = array
  end

  def keyboards
    keyboards = []
    array.each do |text|
      callback = 'word_123'
      keyboards << Telegram::Bot::Types::InlineKeyboardButton.new(text: text, callback_data: callback)
    end
    keyboards
  end

  def get_markup
    Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: keyboards)
  end
end
