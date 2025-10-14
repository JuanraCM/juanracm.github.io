# Personal Blog

Welcome to my personal blog! Here, I share my thoughts, experiences, and knowledge on programming and technology in general.

This blog was built using a custom static site generator written in Ruby. The source code is available on this same repository.

## Installation

To run the static site generator locally, you need to have Ruby installed on your machine. You can then clone this repository and install the required gems:

```sh
cd juanracm.github.io && bundle install
```

## Usage

To build the static site, run the following command:

```sh
bin/build
```

To serve the site locally, run:

```sh
bin/dev
```

The site will be available at `http://localhost:8000`.

### Options

You can specify a different port for the local server by using the `-p` or `--port` option:

```sh
bin/dev -p 8080
```

## Running Tests

To run the tests, use the following command:

```sh
bin/rspec
```
