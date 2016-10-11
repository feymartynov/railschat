function Chat($el, cable) {
  this.$el = $el;
  this.chatName = this.$el.data('name');
  this.cable = cable;
  var self = this;

  this.getChatState(function (state) {
    self.renderState(state);
    self.chatChannel = self.initChatChannel();
    self.setMessageFormSubmitHandler();
  });
}

Chat.prototype.getChatState = function (callback) {
  var self = this;

  return self.cable.subscriptions.create('UserChannel', {
    connected: function () {
      this.perform('get_chat_state', {chat_name: self.chatName});
    },
    received: function (data) {
      if (data.event !== 'chat_state') return;
      callback(data);
      self.cable.subscriptions.remove(this);
    }
  });
};

Chat.prototype.renderState = function (state) {
  var self = this;
  $.each(state.messages, function (_, message) { self.addMessage(message); });
  $.each(state.users, function (_, user) { self.addUser(user); });
};

Chat.prototype.addMessage = function (message) {
  var time = new Date(message.created_at).toISOString().slice(11, 19);

  var html =
    "<li>" +
      "<time class='text-muted'>[" + time + "]</time>&nbsp;" +
      "<strong>@" + message.user.name + ":</strong>&nbsp;" +
      "<span>" + message.text + "</span>" +
    "</li>";

  this.$el.find('#messages').append(html);

  var $panel = this.$el.find("#messages_panel");
  $panel.scrollTop($panel[0].scrollHeight);
};

Chat.prototype.addUser = function (user) {
  var html =
    "<li data-id='" + user.id + "'>" +
      "<span class='online-indicator text-success'>&#9679;</span>" +
      "<strong>@" + user.name + "</strong>" +
    "</li>";

  this.$el.find('#users_list').append(html);
};

Chat.prototype.removeUser = function (user) {
  this.$el.find('#users_list>li[data-id=' + user.id + ']').remove();
};

Chat.prototype.toggleUserOnlineIndicator = function (user, online) {
  this.$el
    .find('#users_list>li[data-id=' + user.id + '] .online-indicator')
    .removeClass('text-success text-danger')
    .addClass(online ? 'text-success' : 'text-danger');
};

Chat.prototype.initChatChannel = function () {
  var self = this;

  return self.cable.subscriptions.create(
    {channel: 'ChatChannel', chat_name: self.chatName},
    {
      received: function (data) {
        switch (data.event) {
          case 'user_joined':
            return self.addUser(data.user);
          case 'user_left':
            return self.removeUser(data.user);
          case 'user_online':
            return self.toggleUserOnlineIndicator(data.user, true);
          case 'user_offline':
            return self.toggleUserOnlineIndicator(data.user, false);
          case 'message_sent':
            return self.addMessage(data.message);
        }
      },
      sendMessage: function (message) {
        this.perform('send_message', {message: message});
      }
    }
  );
};

Chat.prototype.setMessageFormSubmitHandler = function () {
  var self = this;

  self.$el.find('#message_form').submit(function (evt) {
    evt.preventDefault();
    var text = self.$el.find('input[name=message]', this).val();
    self.chatChannel.sendMessage(text);
    this.reset();
  });
};
