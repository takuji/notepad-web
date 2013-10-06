module ApplicationHelper

  def note_page?
    params[:controller] == "my_notes" && params[:action] == "show"
  end

  def title(s)
    content_for :title, s
  end
end
