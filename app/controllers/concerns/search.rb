class Search
  include Virtus.model
  attribute :klass, Class
  attribute :search_attributes, Array, :default => []
  attribute :term, String
  attribute :page, Integer, default: 1
  attribute :per, Integer, default: 15
  attribute :sort_column, Symbol
  attribute :sort_direction, Symbol
  attribute :default_sort_column, Symbol
  attribute :default_sort_direction, Symbol


  def run
    results = base_query
    results = results.where(query, *search_terms) unless term.blank?
    results = apply_order(results)
    results.page(page).per(per).decorate
  end

  def sort_column
    @sort_column || @default_sort_column
  end

  def sort_direction
    @sort_direction || @default_sort_direction
  end

  def ordered_by?(attr)
    attr.to_sym == sort_column
  end

  def order_params_for(attr)
    {
      sort_column: attr,
      sort_direction: reversed_direction_param_for(attr)
    }
  end

  private

  def base_query
    klass.all
  end

  def orderable_columns(results)
    results.columns_hash.keys + virtual_columns.keys
  end

  def virtual_columns
    {}
  end

  def query
    search_attributes.map do |attr|
      "lower(#{table_column_attr(attr)}) LIKE ?"
    end.join(" OR ")
  end

  def table_column_attr(attr)
    virtual_columns[attr.to_s] || attr
  end

  def search_terms
    ["%#{term.downcase}%"] * search_attributes.count
  end

  def apply_order(results)
    if virtual_columns.keys.include?(sort_column.to_s)
      results.order("#{sort_column} #{sort_direction.upcase}")
    elsif orderable_columns(results).include?(sort_column.to_s)
      results.order(sort_column => sort_direction)
    else
      results
    end
  end

  def reversed_direction_param_for(attr)
    if ordered_by?(attr)
      sort_direction == :asc ? :desc : :asc
    else
      :asc
    end
  end

end
