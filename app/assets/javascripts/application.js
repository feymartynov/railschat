//= require action_cable
//= require jquery
//= require jquery_ujs
//= require_tree .

$(function () {
  var cable = ActionCable.createConsumer();
  if ($('#chat')[0]) new Chat($('#chat'), cable);
  new UserChatsList($('#chats_list'), cable);
});
