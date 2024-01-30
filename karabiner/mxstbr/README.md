# @mxstbr's Karabiner Elements configuration

- `https://github.com/mxstbr/karabiner`
- `/Users/krishna/github/dotfiles-latest/karabiner/mxstbr/mxstbr/README.md`

If you like TypeScript and want your Karabiner configuration maintainable & type-safe, you probably want to use the custom configuration DSL / generator I created in `rules.ts` and `utils.ts`!

> “This repo is incredible - thanks so much for putting it together! I always avoided Karabiner mostly because of its complicated configuration. **Your project makes it so much easier to work with and so much more powerful. I'm geeking out on how much faster I'm going to be now.**”
>
> — @jhanstra ([source](https://github.com/mxstbr/karabiner/pull/4))

Watch the video about this repo:

[![YouTube video by Max Stoiber explaining how and why to use this repo](https://img.youtube.com/vi/j4b_uQX3Vu0/0.jpg)](https://www.youtube.com/watch?v=j4b_uQX3Vu0)

You probably don't want to use my exact configuration, as it's optimized for my personal style & usage. Best way to go about using this if you want to? Probably delete all the sublayers in `rules.ts` and add your own based on your own needs!

## Installation

1. Install & start [Karabiner Elements](https://karabiner-elements.pqrs.org/)
1. Clone this repository
1. Delete the default `~/.config/karabiner` folder
1. Create a symlink with `ln -s ~/github/mxstbr/karabiner ~/.config` (where `~/github/mxstbr/karabiner` is your local path to where you cloned the repository)
1. [Restart karabiner_console_user_server](https://karabiner-elements.pqrs.org/docs/manual/misc/configuration-file-path/) with `` launchctl kickstart -k gui/`id -u`/org.pqrs.karabiner.karabiner_console_user_server ``

## Development

```
yarn install
```

to install the dependencies. (one-time only)

```
yarn run build
```

builds the `karabiner.json` from the `rules.ts`.

```
yarn run watch
```

watches the TypeScript files and rebuilds whenever they change.

## License

Copyright (c) 2022 Maximilian Stoiber, licensed under the [MIT license](./LICENSE.md).
