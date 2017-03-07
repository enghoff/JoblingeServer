module ApplicationHelper

  def body_css_classes
    layout_name = controller.send(:_layout).inspect.split("/").last.split(".").first
    classes = []
    classes <<  "mobile" if browser.mobile?
    classes << "ie ie-#{browser.version}" if browser.ie?
    classes << "#{layout_name}-layout"
    classes.join(" ")
  end

  def bootstrap_class_for flash_type
    flash_type = flash_type.to_sym if flash_type.is_a? String
    case flash_type
      when :success
        "alert-success"
      when :error
        "alert-danger"
      when :alert
        "alert-warning"
      when :notice
        "alert-info"
      else
        flash_type.to_s
    end
  end

  def errors_list(model)
    if model.errors.any?
      str= %{
        <div class="alert alert-danger">
          <h4>Errors</h4>
          <ul>#{model.errors.full_messages.map{|msg| content_tag(:li, msg)}.join}</ul>
        </div>
      }.html_safe
    end
    str
  end
end
