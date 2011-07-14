require 'actionpack'
class NotifierHook < Redmine::Hook::Listener

  def controller_issues_new_after_save(context = { })
    @project = context[:project]
    @issue = context[:issue]
    @author = @issue.author
    @assigned_message = @issue.assigned_to.nil? ? "無" : "#{@issue.assigned_to.lastname} #{@issue.assigned_to.firstname}"
    speak "#{@author.lastname} #{@author.firstname} 建立主旨:「#{@issue.subject}」. 狀態:「#{@issue.status.name}」. 分派給:「#{@assigned_message}」. 意見:「#{truncate_words(@issue.description)}」"
    speak "網址: http://#{Setting.host_name}/issues/#{@issue.id}"
  end

  def controller_issues_edit_before_save(context = { })
    @project = context[:project]
    @issue = context[:issue]
    @journal = context[:journal]
    @editor = @journal.user
    @assigned_message = @issue.assigned_to.nil? ? "無" : "#{@issue.assigned_to.lastname} #{@issue.assigned_to.firstname}"
    @status_message = issue_status_changed?(@issue)
    speak "#{@editor.lastname} #{@editor.firstname} 編輯主旨:「#{@issue.subject}」. 狀態:「#{@status_message}」. 分派給:「#{@assigned_message}」. 意見:「#{truncate_words(@journal.notes)}」"
    speak "網址: http://#{Setting.host_name}/issues/#{@issue.id}"
  end

  def controller_messages_new_after_save(context = { })
    @project = context[:project]
    @message = context[:message]
    @author = @message.author
    speak "#{@author.lastname} #{@author.firstname} wrote a new message「#{@message.subject}」on #{@project.name}:「#{truncate_words(@message.content)}」"
    speak "網址: http://#{Setting.host_name}/boards/#{@message.board.id}/topics/#{@message.root.id}#message-#{@message.id}"
  end

  def controller_messages_reply_after_save(context = { })
    @project = context[:project]
    @message = context[:message]
    @author = @message.author
    speak "#{@author.lastname} #{@author.firstname} replied a message「#{@message.subject}」on #{@project.name}: 「#{truncate_words(@message.content)}」"
    speak "網址: http://#{Setting.host_name}/boards/#{@message.board.id}/topics/#{@message.root.id}#message-#{@message.id}"
  end

  def controller_wiki_edit_after_save(context = { })
    @project = context[:project]
    @page = context[:page]
    @author = @page.content.author
    speak "#{@author.lastname} #{@author.firstname} edited the wiki「#{@page.pretty_title}」on #{@project.name}."
    speak "網址: http://#{Setting.host_name}/projects/#{@project.identifier}/wiki/#{@page.title}"
  end

private

  def speak(message)
    system("echo -n '#{message}' | nc localhost 5678")
  end

  def truncate_words(text, length = 20, end_string = '…')
    return if text == nil
    words = text.split()
    words[0..(length-1)].join(' ') + (words.length > length ? end_string : '')
  end

  def issue_status_changed?(issue)
    if issue.status_id_changed?
      old_status = IssueStatu.find(issue.status_id_was)
      "從 #{old_status.name} 變更為 #{issue.status.name}"
    else
      "#{issue.status.name}"
    end
  end

end
