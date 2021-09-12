import consumer from "./consumer"

$(document).on('turbolinks:load', function () {

  consumer.subscriptions.create(
    {
      channel: "PostChannel",
      post_id: $('.post').attr('data-post-id')
    },
    {
      connected() {
        // Called when the subscription is ready for use on the server
        console.log('connected')
      },

      disconnected() {
        // Called when the subscription has been terminated by the server
      },

      received(data) {
        // Called when there's incoming data on the websocket for this channel
        if (data.action == 'new_comment') {
          $('.comments').prepend(data.html)
        }
        if (data.action == 'post_created') {
          $('.posts').prepend(data.html)
        }
        if (data.action == 'post_updated') {
          $(`.post[data-post-id=${data.post_id}]`).replaceWith(data.html)
        }
        if (data.action == 'comment_updated') {
          $(`.comment[data-comment-id=${data.comment_id}]`).replaceWith(data.html)
        }
      }
    });
})