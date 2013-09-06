class EvernoteService
  include Loggable

  def initialize(evernote_account)
    @evernote_account = evernote_account
  end

  attr_reader :evernote_account

  def prepare_notebook
    unless notebook_exist?
      create_notebook
    end
  end

  def notebook_exist?
    evernote_account.notebook.present?
  end

  def create_notebook
    evernote_account.create_notebook
    true
  rescue Exception => e
    logger.error e
    false
  end

  def create_note(note)
    created_note = evernote_account.create_note note
  end
end