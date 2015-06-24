module Fae
  module  ViewHelper

    def fae_date_format(datetime, timezone="US/Pacific")
      datetime.in_time_zone(timezone).strftime('%m/%d/%y')
    end

    def fae_datetime_format(datetime, timezone="US/Pacific")
      datetime.in_time_zone(timezone).strftime("%b %-d, %Y %l:%M%P %Z")
    end

    def fae_path
      Rails.application.routes.url_helpers.fae_path[1..-1]
    end

    def fae_image_form(f, image_name, label: nil, alt_label: nil, caption_label: nil, show_alt: nil, show_caption: nil, required: nil, helper_text: nil, alt_helper_text: nil, caption_helper_text: nil)
      render 'fae/images/image_uploader', f: f, image_name: image_name, label: label, alt_label: alt_label, caption_label: caption_label, show_alt: show_alt, show_caption: show_caption, required: required, helper_text: helper_text, alt_helper_text: alt_helper_text, caption_helper_text: caption_helper_text
    end

    def fae_file_form(f, file_name, label: nil, helper_text: nil, required: nil)
      render 'fae/application/file_uploader', f: f, file_name: file_name, label: label, required: required, helper_text: helper_text
    end

    def fae_content_form(f, attribute, label: nil, hint: nil, helper_text: nil, markdown: nil)
      render 'fae/application/content_uploader', f: f, attribute: attribute, label: label, hint: hint, helper_text: helper_text, markdown: markdown
    end

    def attr_toggle(item, column)
      active = item.send(column)
      link_class = active ? 'slider-yes-selected' : ''
      model_name = item.class.to_s.include?("Fae::") ? item.class.to_s.gsub('::','').underscore.pluralize : item.class.to_s.underscore.pluralize
      url = fae.toggle_path(model_name, item.id.to_s, column)

      link_to url, class: "slider-wrapper #{link_class}", method: :post, remote: true do
        '<div class="slider-options">
          <div class="slider-option slider-option-yes">Yes</div>
          <div class="slider-option-selector"></div>
          <div class="slider-option slider-option-no">No</div>
        </div>'.html_safe
      end
    end
    # for backwards compatibility
    alias_method :fae_toggle, :attr_toggle

    def fae_filter_form(options = {}, &block)
      options[:title]   ||= "Search #{@klass_humanized.pluralize}"
      options[:search]   = true if options[:search].nil?

      form_tag(@index_path + '/filter', remote: true, class: 'js-filter-form table-filter-area') do
        concat content_tag :h2, options[:title]
        concat filter_search_field if options[:search]
        concat capture(&block)
        concat filter_submit_btns
      end
    end

    def fae_filter_select(attribute, options = {})
      options[:label]         ||= attribute.to_s.titleize
      options[:collection]    ||= default_collection_from_attribute(attribute)
      options[:label_method]  ||= :fae_display_field
      options[:placeholder]     = "Select a #{options[:label]}" if options[:placeholder].nil?
      options[:options]       ||= []

      select_options = options_from_collection_for_select(options[:collection], 'id', options[:label_method])
      select_options = options_for_select(options[:options]) if options[:options].present?

      content_tag :div, class: 'table-filter-group' do
        concat label_tag "filter[#{attribute}]", options[:label]
        concat select_tag "filter[#{attribute}]", select_options, prompt: options[:placeholder]
      end
    end

    # this isn't implemented yet, but saving the markup here
    def fae_filter_input(attribute, options = {})
      '<div class="table-filter-group">
        <label for="filter_city">Input</label>
        <input type="text" />
      </div>'.html_safe
    end

    private

    def filter_search_field
      content_tag :div, class: 'table-filter-keyword-wrapper' do
        text_field_tag 'filter[search]', nil, placeholder: 'Search by Keyword', class: 'table-filter-keyword-input'
      end
    end

    def filter_submit_btns
      content_tag :div, class: 'table-filter-controls' do
        concat submit_tag 'Apply Filters'
        concat submit_tag 'Reset Search', class: 'js-reset-btn table-filter-reset'
      end
    end

    def default_collection_from_attribute(attribute)
      attribute.to_s.classify.constantize.for_fae_index
    rescue NameError
      []
    end

  end
end
