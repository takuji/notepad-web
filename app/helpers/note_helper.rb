module NoteHelper
  def note_datetime(time)
    l time, format: :short
  end
end