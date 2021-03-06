require './models/user'
require './models/word'
require './lib/message_sender'
require 'google/cloud/translate'
require './translate/learn'

class MessageResponder
  attr_reader :message
  attr_reader :bot
  attr_reader :user
  attr_reader :translator

  def initialize(options)
    @bot = options[:bot]
    @message = options[:message]
    @user = User.where(uid: message.from.id).first_or_create do |user|
      user.name = "#{message.from.first_name} #{message.from.last_name}"
      user.login = message.from.username
      user.created_at = Time.current
    end
    @translator = Google::Cloud::Translate.new(key: options[:google_api_token])
  end

  def respond
    on /^\/start/ do
      answer_with_greeting_message
    end

    on /^\/stop/ do
      answer_with_farewell_message
    end

    on /^\/list/ do
      answer_with_list
    end

    on /^\/learn/ do
      answer_with_learn_mode
    end

    on /^[aA-zZäÄöÖüÜß]/ do
      translate_word_and_answer
    end

    on /^\u{2754} [aA-zZäÄöÖüÜß]/ do
      answer_with_learn_result
    end

    on /^\/delete [aA-zZäÄöÖüÜß]/ do
      delete_and_confirm
    end
  end

  private

  def on regex, &block
    regex =~ message.text

    if $~
      case block.arity
      when 0
        yield
      when 1
        yield $1
      when 2
        yield $1, $2
      end
    end
  end

  def answer_with_learn_result
    check  = Translate::Learn.new(message.text.strip, user).check_word
    learn   = Translate::Learn.new(message.text.strip, user).push_word

    result_correct = "\u{2705} Correct"
    result_wrong   = "\u{274C} Wrong, \u{1F44D} #{check[:right_answer]}"
    message = (check[:message] == true) ? result_correct : result_wrong
    message = "#{message}\n\n".concat(learn[:message])
    answer_with_answers message, learn[:kb_answers]

  end

  def answer_with_learn_mode
    learn = Translate::Learn.new(message.text.strip, user).push_word
    answer_with_answers learn[:message], learn[:kb_answers]
  end

  def answer_with_list
    words = []
    words += user.words.de_en.pluck(:word, :translate)
    words += user.words.en_de.pluck(:translate, :word)

    message = words.sort_by{|de, en| de }.map{ |de, en| "#{de.capitalize} — #{en}\n"}.join #\u{1F525}
    return answer_with_message I18n.t('errors.empty_list') if message.blank?
    answer_with_message message[0...4096] # tmp fix to limit of response
  end

  def translate_word_and_answer
    text = message.text.strip
    word = user.words.where(word: text).or(user.words.where(translate: text)).first_or_create do |w|
      translate          = translate(text)
      w.word             = text
      w.translate        = translate[:text]
      w.lang_from        = translate[:lang_from]
      w.lang_to          = translate[:lang_to]
      w.word_count       = text.split.count
      w.translate_count  = translate[:text].split.count
      w.created_at       = Time.current
      w.updated_at       = Time.current
    end

    word.update(learn_correct: 0, learn_wrong: 0) if word.passed? # reset learn stats if you ask about word again

    message_out = if word.translate.downcase == message.text.downcase && word.word.downcase == message.text.downcase
                word.delete
                I18n.t('bad_word_income')
              else
                word.translate.downcase == text.downcase ? word.word : word.translate
              end

    answer_with_message message_out
  end

  def answer_with_greeting_message
    answer_with_message I18n.t('greeting_message')
  end

  def answer_with_farewell_message
    answer_with_message I18n.t('farewell_message')
  end

  def delete_and_confirm
    #text = message.text.strip
    answer_with_message "Deleting in progress ..."
  end

  def answer_with_message(text)
    MessageSender.new(bot: bot, chat: message.chat, text: text).send
  end

  def answer_with_answers(text, answers)
    MessageSender.new(bot: bot, chat: message.chat, text: text, answers: answers).send
  end

  def translate(text)
    result = translator.translate text, from: 'de', to: 'en'
    result = translator.translate text, from: 'en', to: 'de' if result.text.downcase == text.downcase
    {text: result.text, lang_from: result.from, lang_to: result.to}
  end
end
