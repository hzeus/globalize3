module Globalize
  module ActiveRecord
    module InstanceMethods
      delegate :translated_locales, :to => :translations

      def attributes
        super.merge(translated_attributes)
      end

      def current_translation_id
        translations.where(locale: Globalize.locale).pluck(:id).first
      end

      def translation_attributes
        if current_translation_id.present?
          { id: current_translation_id }
        else
          { locale: Globalize.locale, id: nil }
        end
      end

      def translation_for(locale = Globalize.locale)
        translations.select{|translation| translation.locale == locale}.first
      end

      def translated?(name)
        self.class.translated?(name)
      end

      def translated_attributes
        translated_attribute_names.inject({}) do |attributes, name|
          attributes.merge(name.to_s => translation.try(name))
        end
      end

      def translation
        translation_for(::Globalize.locale)
      end

      protected

      def each_locale_and_translated_attribute
        used_locales.each do |locale|
          translated_attribute_names.each do |name|
            yield locale, name
          end
        end
      end

      def used_locales
        locales = globalize.stash.keys.concat(globalize.stash.keys).concat(translations.translated_locales)
        locales.uniq!
        locales
      end

      def save_translations!
        globalize.save_translations!
        @translation_caches = {}
      end

      def with_given_locale(attributes, &block)
        attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)
        if locale = attributes.try(:delete, :locale)
          Globalize.with_locale(locale, &block)
        else
          yield
        end
      end
    end
  end
end
