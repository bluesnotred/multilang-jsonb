module Multilang

  class MultilangTranslationKeeper
    attr_reader :model
    attr_reader :attribute
    attr_reader :translations
    attr_reader :sanitizer

    def initialize(model, attribute, sanitizer)
      @model = model
      @attribute = attribute
      @translations = {}
      @sanitizer = sanitizer
      load!
    end

    def value(locale = nil)
      @translations.value(locale)
    end

    def current_or_any_value
      @translations.current_or_any_value
    end

    def current_or_default_value
      @translations.current_or_default_value
    end

    def to_s
      raw_read(actual_locale)  
    end

    def to_str(locale = nil)
      locale ||= actual_locale
      raw_read(locale)
    end

    def update(value)
      if value.is_a?(Hash)
        clear
        value.each { |k, v| write(k, v) if !v.blank?}
      elsif value.is_a?(MultilangTranslationProxy)
        update(value.translation.translations.compact_blank)
      elsif value.is_a?(String)
        write(actual_locale, value)
      end
      flush!
    end

    def [](locale)
      read(locale)
    end

    def []=(locale, value)
      write(locale, value)
      flush!
    end

    def locales
      @translations.locales
    end

    def empty?
      @translations.empty?
    end

    private

    def actual_locale
      @translations.actual_locale
    end

    def write(locale, value)
      @translations[locale.to_s] = @sanitizer ? @sanitizer.call(value) : value
    end

    def read(locale)
      @sanitizer ? @sanitizer.call(@translations.read(locale)) : @translations.read(locale)
    end

    def raw_read(locale)
      @translations[locale.to_s] || ''
    end

    def clear
      @translations.clear
    end

    def load!
      data = @model[@attribute]
      data = data.blank? ? nil : data
      @translations = data.is_a?(Hash) ? data : {}

      class << translations
        attr_accessor :multilang_keeper
        def to_s
          "#{current_or_any_value}"
        end

        def locales
          self.keys.map(&:to_sym)
        end

        def read(locale)
          MultilangTranslationProxy.new(self.multilang_keeper, locale)
        end

        def current_or_default_value
          value.empty? ? value(default_locale) : value
        end

        def current_or_any_value
          v = value
          if v.empty?
            reduced_locales = locales - [actual_locale]
            reduced_locales.each do |locale|
              v = value(locale)
              return v unless v.empty?
            end
          else
            return v
          end
          return ''
        end

        def value(locale = actual_locale)
          read(locale)
        end

        def actual_locale
          I18n.locale
        end

        def default_locale
          I18n.default_locale
        end
      end
      @translations.public_send("multilang_keeper=", self)
    end

    def flush!
      @model.send("#{@attribute}_will_change!")
      @model[@attribute] = @translations
    end

  end
end 
