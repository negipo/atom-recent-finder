# recent-finder

Open recently used file with fizzyfinder.

# Configuration

No default keymap.  
Configure whatever keymap you like in you `keymap.cson`.  

e.g.
```coffeescript
# Since both `cmd-p` and `cmd-t` are mapped to
# `fuzzyfinder:toggle-file-finder` by default.
# I use `cmd-p` for this.
'atom-workspace:not([mini])':
  'cmd-p': 'recent-finder:toggle'
```
