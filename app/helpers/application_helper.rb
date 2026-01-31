module ApplicationHelper
  def tournament_status_color(status)
    case status.to_sym
    when :draft then 'secondary'
    when :registration_open then 'success'
    when :registration_closed then 'warning'
    when :in_progress then 'primary'
    when :completed then 'info'
    when :cancelled then 'danger'
    else 'secondary'
    end
  end
  
  def friendly_date(date)
    if date.today?
      "Hoje, #{l(date, format: :time)}"
    elsif date == Date.tomorrow
      "Amanhã, #{l(date, format: :time)}"
    elsif date < 7.days.from_now
      "#{distance_of_time_in_words(Time.current, date)} atrás"
    else
      l(date, format: :long)
    end
  end
  
  # Gera avatar placeholder
  def avatar_placeholder(name, size: 100)
    initials = name.split.map(&:first).join.upcase[0..1]
    color = Digest::MD5.hexdigest(name)[0..5]
    
    content_tag(:div, 
      initials, 
      class: "avatar-placeholder",
      style: "width: #{size}px; height: #{size}px; background-color: ##{color}; color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: #{size * 0.4}px;"
    )
  end
  
  # Formata números grandes
  def format_large_number(number)
    if number >= 1_000_000
      "#{(number / 1_000_000.0).round(1)}M"
    elsif number >= 1_000
      "#{(number / 1_000.0).round(1)}K"
    else
      number.to_s
    end
  end
  
  # Breadcrumbs
  def breadcrumbs
    return unless content_for?(:breadcrumbs)
    
    content_tag(:nav, class: 'breadcrumb-container') do
      content_tag(:ol, class: 'breadcrumb') do
        yield(:breadcrumbs)
      end
    end
  end
end