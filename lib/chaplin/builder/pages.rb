require_relative '../page'
require_relative 'api_endpoints'

class Chaplin
  module Builder

    Pages = Struct.new(:pages_data, :project_path, :layout_name) do

      def self.load(pages_data, project_path, layout_name = nil)
        new(pages_data, project_path, layout_name).tap do |pages|
          pages.load
        end
      end

      def load
        @pages = {}

        pages_data.each do |template_name, raw_data_hash|
          @pages[template_name] = build_page(template_name, raw_data_hash)
        end

        if layout_name
          @pages = @pages.each_with_object({}) do |(page_name, page), pages_in_layout|
            pages_in_layout[page_name] = embed_in_layout(page)
          end
        end
      end

      def [](page_name)
        @pages[page_name] || build_page(page_name, {})
      end

      private

      def embed_in_layout(page)
        Page.new(layout_path, { content: page })
      end

      def build_page(template_name, raw_data_hash)
        Page.new(template_path(template_name), data_hash(raw_data_hash))
      end

      def template_path(template_name)
        project_path + '/templates/' + template_name
      end

      def layout_path
        @layout_path ||= template_path(layout_name)
      end

      def data_hash(raw_data_hash)
        raw_data_hash.each_with_object({}) do |(key, raw_data_value), data_hash|
          data_hash[key] = build_data(raw_data_value)
        end
      end

      def build_data(raw_data_value)
        if raw_data_value.is_a?(String)
          @pages[raw_data_value]
        else
          ApiEndpoints.build(raw_data_value)
        end
      end

    end

  end
end
