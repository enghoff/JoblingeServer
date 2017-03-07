module Admin::AdminHelper
  include ::DateFormats

  def sortable_link(search, column, title = nil)
    title ||= column.to_s.titleize
    css_classes = []
    css_classes << "table-sortable-header-link"
    css_classes << (search.ordered_by?(column) ? "table-sortable-header-link-current" : "")
    icon_class = (search.ordered_by?(column) && search.sort_direction == :desc) ? "fa fa-sort-desc" : "fa fa-sort-asc"
    link_html = "#{title} <i class='#{icon_class}'></i>".html_safe
    link_to link_html, params.merge( search.order_params_for(column) ), {:class => css_classes.join(" ")}
  end

end
