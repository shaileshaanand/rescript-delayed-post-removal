@val external document: {..} = "document"
@val external window: {..} = "window"

module Post = {
  type t = {
    title: string,
    author: string,
    text: array<string>,
  }

  let make = (~title, ~author, ~text) => {title: title, author: author, text: text}
  let title = t => t.title
  let author = t => t.author
  let text = t => t.text
}

let posts = [
  Post.make(
    ~title="The Razor's Edge",
    ~author="W. Somerset Maugham",
    ~text=[
      "\"I couldn't go back now. I'm on the threshold. I see vast lands of the spirit stretching out before me,
    beckoning, and I'm eager to travel them.\"",
      "\"What do you expect to find in them?\"",
      "\"The answers to my questions. I want to make up my mind whether God is or God is not. I want to find out why
    evil exists. I want to know whether I have an immortal soul or whether when I die it's the end.\"",
    ],
  ),
  Post.make(
    ~title="Ship of Destiny",
    ~author="Robin Hobb",
    ~text=[
      "He suddenly recalled a callow boy telling his tutor that he dreaded the sea voyage home, because he would have
        to be among common men rather than thoughtful acolytes like himself. What had he said to Berandol?",
      "\"Good enough men, but not like us.\"",
      "Then, he had despised the sort of life where simply getting from day to day prevented a man from ever taking
        stock of himself. Berandol had hinted to him then that a time out in the world might change his image of folk
        who labored every day for their bread. Had it? Or had it changed his image of acolytes who spent so much time in
        self-examination that they never truly experienced life?",
    ],
  ),
  Post.make(
    ~title="A Guide for the Perplexed: Conversations with Paul Cronin",
    ~author="Werner Herzog",
    ~text=[
      "Our culture today, especially television, infantilises us. The indignity of it kills our imagination. May I propose a Herzog dictum? Those who read own the world. Those who watch television lose it. Sitting at home on your own, in front of the screen, is a very different experience from being in the communal spaces of the world, those centres of collective dreaming. Television creates loneliness. This is why sitcoms have added laughter tracks which try to cheat you out of your solitude. Television is a reflection of the world in which we live, designed to appeal to the lowest common denominator. It kills spontaneous imagination and destroys our ability to entertain ourselves, painfully erasing our patience and sensitivity to significant detail.",
    ],
  ),
]

let renderNotification = (post: Post.t, id: int, timeoutId, postDiv) => {
  let idString = Belt.Int.toString(id)
  let notificationDiv = document["createElement"]("div")
  notificationDiv["id"] = `block-${idString}`
  notificationDiv["classList"] = `post-deleted pt-1`
  notificationDiv["innerHTML"] = `<p class="flex-center">
This post from <em>${post.title} by ${post.author}</em>
will be deleted in 10 seconds.</p>
<div class="flex-center">
<button id="block-restore-${idString}" class="button button-warning mr-1">Restore</button>
<button id="block-delete-immediate-${idString}" class="button button-danger">Delete Immediately</button>
</div>
<div class="post-deleted-progress"></div>`
  notificationDiv["querySelector"](`#block-restore-${idString}`)["addEventListener"]("click", _ => {
    Js.Global.clearTimeout(timeoutId)
    notificationDiv["parentNode"]["insertBefore"](postDiv, notificationDiv)->ignore
    notificationDiv["remove"]()
  })->ignore

  notificationDiv["querySelector"](
    `#block-delete-immediate-${idString}`,
  )["addEventListener"]("click", _ => {
    Js.Global.clearTimeout(timeoutId)
    notificationDiv["remove"]()->ignore
  })->ignore
  notificationDiv
}

let renderPost = (post: Post.t, id: int) => {
  let idString = Belt.Int.toString(id)
  let postDiv = document["createElement"]("div")
  postDiv["id"] = `block-${Belt.Int.toString(id)}`
  postDiv["classList"] = `post`
  let postContent =
    post.text->Belt.Array.map(post_item => {`<p>${post_item}</p>`})->Belt.Array.joinWith("", x => x)

  postDiv["innerHTML"] = `<div id="block-${idString}" class="post">
  <h2 class="post-heading">${post.title}</h2>
  <h3>${post.author}</h3>
  ${postContent}
  <button id="block-delete-${idString}" class="button button-danger">Remove This Post</button></div>`

  postDiv["querySelector"](`#block-delete-${idString}`)["addEventListener"]("click", _ => {
    let timeoutId = Js.Global.setTimeout(() => {
      document["querySelector"](`#block-${Belt.Int.toString(id)}`)["remove"]()
    }, 10000)
    postDiv["parentNode"]["insertBefore"](
      renderNotification(post, id, timeoutId, postDiv),
      postDiv,
    )->ignore
    postDiv["remove"]()->ignore
  })->ignore
  postDiv
}

posts
->Belt.Array.mapWithIndex((i, post) => {
  renderPost(post, i)
})
->Belt.Array.forEach(post => document["body"]["appendChild"](post))
