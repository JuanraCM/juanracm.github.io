---
title: Discovering Nix & NixOS
desc: How I discovered Nix and NixOS, and how it has changed my view on software development and system configuration.
layout: post
date: 2026-03-02
---

A few months ago, I bought a new laptop and decided to embark on an exciting *distro-hopping* adventure. I wanted to explore different Linux distributions and find the one that best suits my needs. The one that caught my attention at first was Arch Linux, which I had already tried before thanks to [Omarchy](https://omarchy.org/), and it inspired me to build my own Arch-based configuration (which in fact I did, you can check it out [here](https://github.com/JuanraCM/arch-config)).

However, after a few weeks of fixing update breakages and dealing with the maintenance that Arch Linux requires, I realized I wanted something more stable. That's when I stumbled upon [NixOS](https://nixos.org/), a Linux distribution built around the Nix package manager. For those who don't know, Nix is a powerful package manager that allows you to manage software in a declarative way, and NixOS takes this concept to the next level by using it to manage the entire system configuration. After reading about it and watching a few videos, I decided to give it a try.

## What Clicked Right Away

When I first learned about NixOS, I found it very intriguing, but at the same time a bit overwhelming, as I'd been warned that it has a steep learning curve (and at that moment I just wanted to get my laptop up and running).

Once I got it installed, I was amazed by how easy it was to manage my system configuration. Installing and dropping packages was a breeze, and fixing configuration issues was as easy as rolling back to the previous generation and figuring out what went wrong without worrying about breaking my system. 

## Cool Stuff I Found

As I started exploring the Nix ecosystem, I discovered a lot of interesting tools and projects built around it. For example, [Flakes](https://nixos.wiki/wiki/Flakes) pin the exact versions of the packages and dependencies you are using, making it easier to reproduce your environment and share it with others, no more "it works on my machine" issues.

Also, [nix-shell](https://nixos.wiki/wiki/Development_environment_with_nix-shell), allows you to create isolated development environments with specific dependencies and tools, so you can work on different projects without dependency conflicts bleeding into each other (by the way, you can combine them with Flakes using the [nix develop](https://nix.dev/manual/nix/2.18/command-ref/new-cli/nix3-develop) command).

These are just a couple of examples, but the ecosystem goes much deeper. There are many other tools such as [home-manager](https://nix-community.github.io/home-manager/), a project to manage the content of your home directories like configuration files, environment variables, and more, or [stylix](https://nix-community.github.io/stylix/), a *plug-and-play* theming framework that automatically applies color schemes, wallpapers and fonts to a wide range of applications and desktop environments, making it easier to customize the look and feel of your system.

## The Rough Edges

Of course, like any tool, NixOS has its downsides. As I mentioned before, it has a steep learning curve, and it can be quite difficult to deal with the issues that arise from time to time, especially given the fact that the documentation is not precisely the best out there.

On top of that, when you want to install a package that is not available on nixpkgs, it can be a little bit tricky to figure out how to build it from source, especially if you are not familiar with the Nix language and its build system.

Last but not least, since your NixOS configuration is essentially a project, it can turn into a bit of a mess if you don't keep it organized and well-structured, especially if you tend to add a lot of custom configurations and packages.

## Final Thoughts

Overall, discovering Nix and NixOS has been a very rewarding experience. It has changed the way I think about software development and system configuration. However, while it may not be the best choice for everyone, I highly recommend giving it a try on a virtual machine or a spare computer, as it can be a quite fun experience :)

Safe to say that I will be using NixOS as my main operating system for the foreseeable future, and I'm really excited about it. If you're curious about my NixOS configuration, you can also check it out on my [GitHub repository](https://github.com/JuanraCM/nixos-config). Feel free to reach out if you have any questions or suggestions!
