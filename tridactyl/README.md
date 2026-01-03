# Tridactyl Config

Vim-style keyboard navigation for Firefox using [Tridactyl](https://github.com/tridactyl/tridactyl).

## Installation

1. Install [Tridactyl](https://addons.mozilla.org/en-US/firefox/addon/tridactyl-vim/) from Firefox Add-ons
2. Run `:nativeinstall` in Firefox to enable native features
3. Symlink config: `ln -s ~/dotfiles/tridactyl ~/.config/tridactyl`
4. Run `:source` in Firefox to load the config

## Theme

Custom **Matrix** theme - bright green (#00ff41) on near-black background.

## Keybindings

### Navigation
| Key | Action |
|-----|--------|
| `j/k` | Scroll down/up |
| `h/l` | Scroll left/right |
| `gg/G` | Top/bottom of page |
| `d/u` | Half page down/up |
| `f` | Hint mode (open link) |
| `F` | Hint mode (open in new tab) |

### Tabs
| Key | Action |
|-----|--------|
| `J/K` | Previous/next tab |
| `gt/gT` | Next/previous tab |
| `d` | Close tab (move left) |
| `D` | Close tab |
| `t` | Open new tab |
| `T` | Open new background tab |
| `yd` | Duplicate tab |
| `gd` | Detach tab to window |
| `gp` | Pin/unpin tab |
| `gm` | Mute/unmute tab |
| `<<` | Move tab left |
| `>>` | Move tab right |

### Clipboard
| Key | Action |
|-----|--------|
| `yy` | Copy current URL |
| `Y` | Hint to copy link URL |
| `p` | Open clipboard URL in new tab |
| `P` | Open clipboard URL in current tab |

### Other
| Key | Action |
|-----|--------|
| `/` | Find in page |
| `n/N` | Next/previous match |
| `gr` | Reader mode |
| `gi` | Focus first input |
| `;c` | Toggle comments (Reddit/HN) |
| `;g` | Copy git clone command |

### Quickmarks
| Key | Site |
|-----|------|
| `gog` | GitHub |
| `gom` | Gmail |
| `goy` | YouTube |
| `gor` | Reddit |
| `goh` | Hacker News |

## Search Engines

Use `:open <engine> <query>` or `:tabopen <engine> <query>`

| Engine | Site |
|--------|------|
| `g` | Google |
| `ddg` | DuckDuckGo |
| `gh` | GitHub |
| `yt` | YouTube |
| `wiki` | Wikipedia |
| `mdn` | MDN Web Docs |
| `npm` | npm |
| `rs` | Rust docs |
| `py` | Python docs |

## Useful Commands

- `:help` - Open help page
- `:tutor` - Interactive tutorial
- `:source` - Reload config
- `:colours matrix` - Apply matrix theme
- `:set <key> <value>` - Change setting
- `:bind <key> <action>` - Add keybinding
