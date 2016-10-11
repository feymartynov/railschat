function UserChatsList($el, cable) {
  this.$el = $el;
  this.cable = cable;
  var self = this;

  $.each($el.find('li'), function (_, li) {
    if ($(li).hasClass('active')) return;
    var chatName = $(li).data('chat-name');
    self.watchChat(chatName);
  });
}

UserChatsList.prototype.watchChat = function(chatName) {
  var self = this;

  return self.cable.subscriptions.create(
    {channel: 'ChatChannel', chat_name: chatName},
    {
      received: function (data) {
        if (data.event !== 'message_sent') return;
        self.notifyAboutNewMessage(chatName);
      }
    }
  );
};

UserChatsList.prototype.notifyAboutNewMessage = function(chatName) {
  var $li = this.$el.find('li[data-chat-name="' + chatName + '"]');
  if ($li.find('.new-messages-indicator')[0]) return;

  var html = "&nbsp;<span class='new-messages-indicator text-success'>&#9679;</span>";
  $li.find('a').append(html);
};
