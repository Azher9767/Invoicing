class FormPresenter
  attr_reader :model, :template, :default_class

  FORM_INVALID = '%s %s is-invalid'
  ARIA = '%s_aria'
  INVALID_FEEDBACK = 'invalid-feedback'
  REQUIRED = 'required %s'

  def initialize(model, template, default_class)
    @model = model
    @template = template
    @default_class = default_class
  end

  def field_options(attr, html_class = nil, options = {})
    if errors[attr].present?
      {
        class: format(FORM_INVALID, default_class, html_class),
        aria: { describedby: format(ARIA, attr) }
      }
    else
      { class: "#{default_class} #{html_class}".strip }
    end.merge(options)
  end

  def error_container_for(attr)
    if errors[attr].present?
      template.tag.div(class: INVALID_FEEDBACK, id: format(ARIA, attr)) do
        errors[attr].join(',').html_safe
      end
    end
  end

  def label(attr, html_class = nil)
    template.tag.label(class: "#{label_classes(attr, html_class)}") do
      attr.to_s.humanize.html_safe
    end
  end

  private

  def errors
    @errors ||= model.errors
  end

  def label_classes(attr, html_classes)
    mandatory_attrs.include?(attr) ? format(REQUIRED, html_classes) : html_classes
  end

  def mandatory_attrs
    @mandatory_attrs ||= model.class.validators
      .select { |v| v.class == ActiveRecord::Validations::PresenceValidator }
      .map(&:attributes)
      .flatten
  end
end
