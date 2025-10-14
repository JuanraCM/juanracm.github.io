---
title: SSG from scratch
desc: My first blog post, where I share my journey of building this blog using a custom static site generator.
layout: post
date: 2025-10-12
---

Building a static blog like this one is an idea that has been wandering in my mind for a while. After trying a few static site generators (like Jekyll, Hugo or Astro), none of them really felt like "the one", so I decided to try building my own from scratch.

## Why build my own SSG?

Well, there are a few reasons:

1. **Customization**: I wanted a tool that perfectly fits my needs and preferences, without the bloat of features I don't use.

2. **Learning Experience**: I wanted to deepen my understanding of how static site generators work under the hood and gain hands-on experience in building one myself.

3. **Because I can**: I don't think I need to explain this one, do I?

## The Journey

It all started with a simple idea: read markdown files, convert them to HTML, and generate a static website. I decided to use Ruby for this project, as I'm quite familiar with it and it already ships some great libraries like ERB for templating.

Firstly, I set up a basic `build.rb` script that could read ERB templates and markdown files. Then, I used the [commonmarker](https://github.com/gjtorikian/commonmarker) gem to convert markdown to HTML. It turned out to be quite simple and straightforward. In fact, here's a simplified version of the core logic:

```ruby
require 'commonmarker'
require 'erb'

Dir.glob("pages/*.md").each do |file|
  page_content = File.read(file)
  layout_template = ERB.new(File.read("layouts/post.html.erb"))

  html_content = Commonmarker.to_html(page_content)
  output = layout_template.result(content: html_content)

  File.write("build/#{File.basename(file, '.md')}.html", output)
end
```

Then, I decided to implement a very simple hot reload feature using [listen](https://github.com/guard/listen) gem, which watches for file changes in a separate thread and triggers a rebuild whenever a file is modified. This made the development process much smoother, as I could see my changes reflected when reloading the browser.

Later on I decided to add a simple polling system in JavaScript that reloads the browser automatically when a change is detected, which looked something like this:

```javascript
let refreshedAt;

setInterval(() => {
  console.info('Checking for updates...');

  fetch('/refresh.txt')
    .then(response => response.text())
    .then(data => {
      if (refreshedAt && refreshedAt !== data) {
        window.location.reload();
      }
        refreshedAt = data;
      });
}, 1000);
```
> **Note**: I know this is not the most efficient way to implement automatic browser reloading, but it works well enough for my needs and it was very easy to set up.

Finally, I worked on the design and layout of the blog. I was heavily inspired by [Dax Raad's](https://thdxr.com/) blog design, which I really liked for its simplicity and readability (as you can see, I didn't stray too far from the original design, but I plan to make it stand out more in the future).

## Conclusion

Building this project was a very fun and rewarding experience. It allowed me to understand how static site generators work under the hood, and I now have a tool that perfectly fits my needs. Maybe in the future I'll isolate the SSG into its own gem and share it with the world, who knows?

If you're interested in the code, you can check out the [repository on GitHub](https://github.com/JuanraCM/juanracm.github.io). Feel free to reach out if you have any questions or suggestions!
