class EvernoteAccount < ActiveRecord::Base
  class << self
    def oauth_client
      EvernoteOAuth::Client.new
    end

    def attrs_to_exclude
      @attrs_to_exclude ||= %w(id class)
    end
  end

  belongs_to :user

  after_create do
    user.update_column :use_evernote, true
  end

  after_destroy do
    user.update_column :use_evernote, false
  end

  def notebooks
    note_store.listNotebooks(oauth_token)
  end

  # Returns the notebook for this application
  def notebook
    @notebook ||= note_store.listNotebooks.select{|notebook| notebook.name == notebook_name}.first
  end

  def create_notebook
    notebook = Evernote::EDAM::Type::Notebook.new
    notebook.name = notebook_name
    note_store.createNotebook oauth_token, notebook
  end

  def create_note(note)
    content =<<-END
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE en-note SYSTEM "http://xml.evernote.com/pub/enml2.dtd">
<en-note>#{note.html_content}</en-note>
    END
    content = preprocess_xml content
    logger.debug content
    e_note = Evernote::EDAM::Type::Note.new
    e_note.title = note.title
    e_note.content = content
    e_note.notebookGuid = notebook.guid

    created_note = note_store.createNote(e_note)
    note.update_column :evernote_guid, created_note.guid
  rescue Evernote::EDAM::Error::EDAMUserException => edue
    ## Something was wrong with the note data
    ## See EDAMErrorCode enumeration for error code explanation
    ## http://dev.evernote.com/documentation/reference/Errors.html#Enum_EDAMErrorCode
    logger.error "EDAMUserException: #{edue} #{edue.errorCode}, #{edue.parameter}"
  rescue Evernote::EDAM::Error::EDAMNotFoundException => ednfe
    ## Parent Notebook GUID doesn't correspond to an actual notebook
    logger.error "EDAMNotFoundException: Invalid parent notebook GUID"
  end

private

  def note_store
    @note_store ||= client.note_store
  end

  def client
    p oauth_token
    @client ||= EvernoteOAuth::Client.new(token: oauth_token)
  end

  def preprocess_xml(xml)
    doc = Nokogiri::XML.parse xml
    doc.css('h1,h2,h3,h4,h5,h6,code').each do |elm|
      self.class.attrs_to_exclude.each{|attr| elm.remove_attribute(attr)}
    end
    doc.to_s
  end
end
