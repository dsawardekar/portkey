## Portkey [![Build Status][22]][23] [![Dependency Status][24]][25]

### Navigate files at the speed of Vim.

Portkey allows you move around files in your project quickly. It is a port of the `rails-projections`
feature of [vim-rails][1] written in [Riml][2]. It works especially well if your project is well organized with
common patterns of moving between files.

## How it works

At the root of your project you create a file called `portkey.json`. In this file
you describe the file structure of your project and the relations between files. Portkey
uses this file to provide mappings and Ex commands to allow you jump to and between these files.

The format of this file is similar to that used by vim-rails's projections.json, with minor enhancements.
A sample `portkey.json` looks like below,

```json
{
  "app/models/*.rb": {
    "type": "model",
    "alternate": "tests/models/%s_test.rb"
  }
}
```

The above portkey declares a `model` and it's `alternate`. This allows you to navigate to any model
that matches this pattern with the Ex command, `:Emodel`.

There are a few different ways to switch to a different file, depending on whether you need to
open a file related to the current file or to *search* for a specific project file.

## Navigation with Alternate :A


Alternates are provided with the Ex command, `:A`.

To jump to an alternate file you first need to specify an alternate in the portkey.json.

```json
{
  "app/models/*.js": {
    "type": "model",
    "alternate": ["app/fixtures/%s.js"]
  }
}
```

Now in any model hitting `:A` will switch to the fixture for that model.
From the `post` model this command will take you to `app/fixtures/post_fixture.js`.

The default `alternate` for a file is it's `test` if specified. To jump to a test file you specify a `test` in the portkey.json

```json
{
  "app/models/*.js": {
    "type": "model",
    "alternate": "app/fixtures/%s_fixture.js",
    "test": "test/models/%s_test.js"
  }
}
```

Here the files `app/models/author.js` would have 2 alternates, `author_fixture.js` and `author_test.js`

You can specify more than one file as an `alternate` or `test`. The file with the best match will
be switched to by default. You can use `<count>` to jump to a specific alternate.

For instance, `:2A` will jump to the second alternative, and so on.

## Navigation with Related :R

Similar to alternate files you can use the Ex command `:R` to jump to a file related to the current file.
For instance to jump to helpers from controllers, You specify a `related` for a projection pattern like below.

```json
{
  "app/controllers/*_controller.js": {
    "type": "controller",
    "related": "app/helpers/%s_helper.js"
  }
}
```

Multiple `related` files can be specified using an array instead of a string. And `<count>`(Eg:- `:2R`) can be used to jump
to a specific `related` file.

## Navigation with Resource commands :Eresource

By declaring a projection in the `portkey.json` with a `type`, you
create a `resource` command of that name. These commands are of the form
`:(E|S|V|T|D){resource_name}`. They provide support for auto-completion to filter the exact file to open.

Eg:- a `model` gets the resource commands, `Emodel`, `Smodel`, etc.

The variants available and their operations are listed below.

Variant | Operation
----|------
:E | open in current buffer
:V | open in vertical split
:S | open in horizontal split
:T | open in new tab
:D | read contents of file into current buffer

## Creating New Files with Bang!

The `alternate`, `related`, and `resource` commands can all be used to create new
files with an additional `bang` character `!` at the end of the Ex command. The new files are created
in the directory as specified by your resource.

`:Emodel category!` creates a new file `app/models/category.js` as per your
projection pattern.

The `alternate` and `related` Ex commands also support file creation with bang.

If your model has a `related` of fixture, then `:R!` from `post.rb` will
create a new file `post_fixture.rb`.

Similarly given a model with an alternate test, `:A!` from `author.rb` will
create a new file `author_test.rb`.

Note: The directory of the resource will be created automatically if it doesn't
exist. This feature relies on `mkdir`, and may not work if your Vim does not support  `mkdir`.


## New File Boilerplate

Projections can include a `template` key to specify initial boilerplate for that
resource type. This template language is identical to that used to specify `alternate` and
other relations. It supports the same `modifiers` and `placeholders`.

In addition `\n` converts to newlines. And `\t` to tabs or spaces based on the current
tab settings.

```json
{
  "app/models/*.js": {
    "type": "model",
    "template": "%S = DS.Model.extend({\n\t\n});"
  }
}
```

Here the `template` will provide boilerplate for a new [ember-data][16] model.

## Navigation with the CtrlP and Adaptive Mappings

Note: This feature requires [CtrlP][3] to be installed. A `<LocalLeader>`
key must also be set. You can set a `<LocalLeader>` like below,

```viml
let g:maplocalleader = ';'
```

In addition to the resource Ex commands Portkey provides an even faster way to search and open
a specific file. It adds a custom [CtrlP][3] menu to allow opening files with CtrlP's fuzzy matching feature. A short
custom mapping(Eg:- `;m` for models) opens this menu.

These mappings begin with a `<LocalLeader>` like `<LocalLeader>m` for models. Given a `<LocalLeader>`
semicolon, this would give you the normal mode mapping, `;m`. Typing in a few keys to match on the model's name filters
the list and gives you the file to open.

Hitting enter opens the file in the current buffer. Additionally you have access to CtrlP's mappings
like `Ctrl-s` or `Ctrl-v` to open in a horizontal or vertical split respectively.

This feature is best explained with an example. Given a project with Model-View-Controllers stored
in app/models, app/controllers, app/views.  You can describe this in a `portkey.json` as,

```json
{
  "app/models/*.js": {
    "type": "model"
  },
  "app/controllers/*.js": {
    "type": "controller"
  },
  "app/views/*.js": {
    "type": "view"
  }
}
```

This will give you the mappings,

Mapping        | Resource
---------------|---------
`<LocalLeader>m` | model
`<LocalLeader>c` | controller
`<LocalLeader>v` | view

Hitting any of these mappings will open up a CtrlP finder which can be used
to fuzzy match on that resource type.

With a number of overlapping resource names these mappings can get
long. Eg: `component` and `controller`, would become `comp` and `cont`
respectively.

Portkey tries to shorten the mappings to 2 characters when possible.
Above, `component` and `controller` would be shortened as `cm` and `cn`
respectively.

You can override the default mapping for a resource by using the `mapping`
key.

```json
{
  "app/controllers/*.js": {
    "type": "controller",
    "mapping": "c"
  },
  "app/components/*.js": {
    "type": "component",
    "mapping": "n"
  }
}
```

Note: Conflict handling is left to the user when custom
mappings are used.

To view the available mappings for a project use,

```viml
<LocalLeader><LocalLeader>
```

or the Ex command

```viml
:PortkeyMappings
```

## Navigation with `gf`

Portkey adds a custom `includeexpr` to provide custom `gf` searching. The default `Get File` finder
tries different variants of the word under the cursor with patterns
inside your portkey.json.

The default finder can find filenames directly mapping on to resources. Eg:- Hitting `gf` on
the word `Container` will take you to the resource matching `container`.

This feature is meant to be augmented by Portkey extensions. Eg:- `gf` on a line with an `import`
statement would go to the imported file.

The exact behaviour that matches such an `import` statement varies and hence is
left to extensions to implement.

## Extract with `<range>`

Portkey provides basic re-factoring similar to `vim-rails`'s `:Rextract`. The difference
is Portkey's extraction is done by providing a `range` to it's resource commands.

Every Resource command can take an optional `<range>` prefix. Visual mode ranges are also supported.

```viml
:5,10Emodel comment
```

Here, Portkey grabs the lines 5-10 and creates a new model `comment` and puts these lines into it
and deletes the lines in the original file. If the target file already exists, the contents are appended to the file.

The base implementation doesn't write anything back into the
source of the extraction, like an `include` statement. Nor does it wrap the contents inside say a
`class` body.

Extensions may augment this feature to do this wrapping. The
base implementation is equivalent to a `cut-and-paste` operation across files.

## Running Current Test with :Run

You can run tests for the currently open file using :PortkeyRunner. This commands expects
you to declare a `compiler` attribute equal to the Vim compiler plugin to use to run the test.

```json
{
  "app/models/*.js": {
    "type": "model",
    "compiler": "jasmine"
  }
}
```

Then using,

```viml
:PortkeyRunner
```
or it's alias,
```viml
:Run
```

will run the current file or it's corresponding test against [Jasmine's][4] Vim compiler plugin.
If the test has errors they are opened in a quickfix window.

Note: Resource `type` names ending in `test` or `spec` are considered tests.

## Projection Patterns

A `Projection` is a json object describing a file pattern and it's corresponding relations. At the
very least it must have a `pattern` and a `type`.

```json
{
  "app/controllers/*_controller.rb": {
    "type": "controller"
  }
}
```

Note: `type` must be a valid Ex command name. Avoid underscores and other characters
that are invalid as Ex command names.

Patterns should contain a `*` which acts as a placeholder for the filename. This placeholder
name can be used as `%s` or `%{source}` in the relation templates to describe the file
to switch to.

Pattern | Match Type | Example Pattern | Filename | %s
------|--------|----------|----|-----
`*` | non-recursive match | `app/models/*.js` | `app/models/post.js` | post
`**` | recursive match | `app/models/**.js` | `app/models/admin/post.js` | admin/post.

Note: Recursive matches can be slow depending on how deep the search needs to be. Avoid
recursive matching of unrelated resources unless you are certain that the directory structure isn't very deep.
Instead create additional projections for each pattern inside the folder, whenever possible.

The relations of a file are described with the keys, `alternate`, `related` and `test`. These
keys can be a single string or any array of strings. The contents of this string determine
how the original file is transformed into the related file.

For the pattern `app/models/*.rb`, with a file, `app/models/post.rb`, the matched `source`
variable would be `post`.

This string template can contain `modifiers` and `placeholders` to transform the source name.

Supported modifiers

Modifier | Transformation
----|-----
%s | matched source name
%S | camelcased source
%p | pluralized source
%i | singular source
%h | humanized source

Placeholders allow additional customization of the source name.

The syntax for placeholders is, `%{source|filter1|filter2}`

```erb
%{source|underscore|camel}
```

Here, the source is first underscorized then camelized.

## Editing and Reloading Portkey.json

To edit the portkey for a project. Use,

```viml
:OpenPortkey
```
or it's alias,
```viml
:PK
```

The json loader used by Portkey cannot identify errors like missing
commas. It is recommended that you install [Syntastic][6]
with [jsonlint][7] to quickly identify such errors.
Portkey will only report a basic failure message if it is unable to load or parse the portkey.json file.

When a portkey.json file is modified it's projections are reloaded automatically. You can also manually reload with,

```viml
:PortkeyRefresh[!]
```

Without bang it only clears the opened buffers. Reopening the buffer will rematch it against the loaded projections.
With bang the entire project's context is reloaded, including it's `portkey.json` and any included extensions.

## Example Portkeys

1. [Portkey][21]!!!
2. [Speckle][27]

## Configuration Options

* portkey_autostart

  Opening Vim inside a project with a `portkey.json` starts Portkey automatically.
  Without this you have to first open a buffer inside that project.

  Default: 1 (true)

* portkey_adaptive_mappings

  Whether to use `<LocalLeader>` mappings. You will also need CtrlP installed and
  a `maplocalleader` assigned for this feature to work.

  Default: 1 (true)

## Extensions

Portkey can be augmented by extensions especially for frameworks that have a predictable
folder layout. An extension can be loaded in a `portkey.json` by using the `portkeys` attribute.

```json
{
  "portkeys": ["ember"]
}
```

This will load the [emberjs][17] extension and all it's projections.

Things extensions can do,

- Add custom finders and rankers
- Add custom template filters
- Configure defaults for projections
- Add custom extractors

## System Requirements

Portkey is a native Viml extension, compiled from [Riml][2]. The following
Vim extensions are recommended but optional.

Recommended configuration

* [CtrlP][3] - *Highly Recommended*. Without CtrlP, adaptive mappings will be disabled.
* [Syntastic][6] + [jsonlint][7] - For detecting errors when editing portkey.json
* [vim-json][5] - Improved syntax highlighting and code folding of json

## Installation

##### 1. With [Vundle][18]
`Bundle 'dsawardekar/portkey'`

##### 2. With [Pathogen][19]
`git clone https://github.com/dsawardekar/portkey ~/.vim/bundle/portkey`

## TODO

Portkey is a work-in-progress. Following are some of the things to be done.

1. Implement [vim-rails's][1] jumps feature
2. Test on Windows
3. Document the Extension API
4. Document Affinity
5. Document Placeholders

## FAQ

> What's a Portkey?

> Magical means of transportation. Takes you where you need to go, fast!

## Authors

* Darshan Sawardekar [@_dsawardekar][26]

## Thanks

This project couldn't have been possible without the support of the following
people. Many thanks for your kindness and generosity.

1. [Luke Gruber][11] - for [Riml][2]! I don't think I would have attempted this
   plugin without it.
2. [Tim Pope][12] - For [vim-rails][1] and for taking over my vimrc.
3. [Kien][13] - For [CtrlP][3], without it Portkey would probably be called Floo Powder!
4. [Abdul Qabiz][14] - For opening my eyes to the world of Vim plugins.

## Contributing

Portkey is developed almost entirely in [Riml][2]. The files in
`plugin` and `autoload` folders are compiled files. The source files
live in the lib directory.

Pull Requests should be against source code not the compiled files.
The compiled files are autogenerated before a release. Further the project
uses [git-flow][10] based branching model. Pull requests should go against
the develop branch.

Portkey uses [Speckle][15] for testing. PR's with tests are preferred.


## License

MIT License. Copyright © 2013 Darshan Sawardekar.




[1]: https://github.com/tpope/vim-rails
[2]: https://github.com/luke-gru/riml
[3]: https://github.com/kien/ctrlp.vim
[4]: http://pivotal.github.io/jasmine
[5]: https://github.com/elzr/vim-json
[6]: https://github.com/scrooloose/syntastic
[7]: https://github.com/codenothing/jsonlint
[8]: https://github.com/majutsushi/tagbar
[9]: https://github.com/nono/vim-handlebars
[10]: https://github.com/nvie/gitflow
[11]: https://github.com/luke-gru
[12]: https://github.com/tpope
[13]: https://github.com/kien
[14]: https://github.com/abdul
[15]: https://github.com/dsawardekar/speckle
[16]: https://github.com/emberjs/data
[17]: https://github.com/dsawardekar/ember.vim
[18]: https://github.com/gmarik/vundle
[19]: https://github.com/tpope/vim-pathogen
[20]: https://github.com/emberjs/ember.js
[21]: https://github.com/dsawardekar/portkey/blob/develop/portkey.json

[22]: https://travis-ci.org/dsawardekar/portkey.png
[23]: https://travis-ci.org/dsawardekar/portkey
[24]: https://gemnasium.com/dsawardekar/portkey.png
[25]: https://gemnasium.com/dsawardekar/portkey
[26]: https://www.twitter.com/_dsawardekar
[27]: https://github.com/dsawardekar/speckle/blob/develop/portkey.json

