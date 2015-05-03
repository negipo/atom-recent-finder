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

# Settings

* `recent-finder:syncImmediately`: Save recent entries to localStorage on every file open and always read etnries from localStorage. If you want to sync entries across multiple atom windows immediately, this option is for you.

# Commands

* `recent-finder:toggle`: toggle recent-finder
* `recent-finder:clear`: clear all entry, use this if you are in trouble.
