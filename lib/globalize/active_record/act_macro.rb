module Globalize
  module ActiveRecord
    module ActMacro
      def translates(*attr_names)

        options = attr_names.extract_options!
        attr_names = attr_names.map(&:to_sym)

        unless translates?
          options[:table_name] ||= "#{table_name.singularize}_translations"
          options[:foreign_key] ||= class_name.foreign_key

          class_attribute :translated_attribute_names, :translation_options
          self.translated_attribute_names = []
          self.translation_options        = options

          include InstanceMethods
          extend  ClassMethods

          translation_class.table_name = options[:table_name] if translation_class.table_name.blank?

          has_many :translations, :class_name  => translation_class.name,
                                  :foreign_key => options[:foreign_key],
                                  :dependent   => :destroy,
                                  :autosave    => true,
                                  :extend      => HasManyExtensions
          accepts_nested_attributes_for :translations
          attr_accessible :translations_attributes

        end

        new_attr_names = attr_names - translated_attribute_names
        new_attr_names.each { |attr_name| translated_attr_accessor(attr_name) }
        self.translated_attribute_names += new_attr_names
      end

      def class_name
        @class_name ||= begin
          class_name = table_name[table_name_prefix.length..-(table_name_suffix.length + 1)].downcase.camelize
          pluralize_table_names ? class_name.singularize : class_name
        end
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end
    end

    module HasManyExtensions
      def find_or_initialize_by_locale(locale)
        with_locale(locale.to_s).first || build(:locale => locale.to_s)
      end
    end
  end
end
