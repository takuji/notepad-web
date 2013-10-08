module ApplicationHelper

  def note_page?
    params[:controller] == "my_notes" && params[:action] == "show"
  end

  def title(s)
    content_for :title, s
  end

  def first_page?
    params[:page].blank? || params[:page].to_i <= 1
  end
end
