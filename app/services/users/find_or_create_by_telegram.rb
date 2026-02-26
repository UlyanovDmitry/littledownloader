require 'json'

module Users
  class FindOrCreateByTelegram
    attr_reader :params
    private :params

    def self.call(validator)
      new(validator).call
    end

    def initialize(validator)
      @params = validator.params || {}
    end

    def call
      tg = parse_telegram_user(params['user'])
      tg_id = tg['id']&.to_s
      raise ArgumentError, 'telegram user id is missing' if tg_id.blank?

      user = User.find_or_initialize_by(tg_id: tg_id)

      # Update profile on each login (safe fields)
      user.tg_username = tg['username'] if tg.key?('username')
      user.first_name = tg['first_name'] if tg.key?('first_name')
      user.last_name = tg['last_name'] if tg.key?('last_name')
      user.photo_url = tg['photo_url'] if tg.key?('photo_url')
      # user.language_code = tg['language_code'] if tg.key?('language_code')

      # Default role is assigned by the migration (user)
      user.save! if user.changed?
      user
    end

    private

    def parse_telegram_user(user_json)
      return {} if user_json.to_s.strip.empty?
      JSON.parse(user_json.to_s)
    rescue JSON::ParserError
      {}
    end
  end
end
