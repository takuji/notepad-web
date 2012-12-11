module ApplicationHelper

  def note_page?
    params[:controller] == "my_notes" && params[:action] == "show"
  end
end
