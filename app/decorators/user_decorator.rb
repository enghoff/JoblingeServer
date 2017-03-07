class UserDecorator < ApplicationDecorator
  delegate_all

  def registration_code
    # "f1948c5569c5" => "F194-8C55-69C5"
    object.registration_code.to_s.chars.each_slice(4).map(&:join).join("-").upcase
  end

  def group
    object.group.try(:name)
  end

  def location
    object.location.try(:name)
  end

end
