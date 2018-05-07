const {CompositeDisposable} = require('atom');
const fs = require('fs-plus');
const _ = require('underscore-plus');

const requireFromPackage = function(packageName, fileName) {
  const path = require('path');
  const packageRoot = atom.packages.resolvePackagePath(packageName);
  const filePath = path.join(packageRoot, 'lib', fileName);
  return require(filePath);
};

const FuzzyFinderView = requireFromPackage('fuzzy-finder', 'fuzzy-finder-view');

// Hisotry management
// -------------------------
class History {
  constructor(scope) {
    this.scope = scope;
  }

  add(filePath) {
    let items = this.getAllItems();
    items.unshift(filePath);
    items = _.uniq(items);
    items.splice(atom.config.get('recent-finder.max'));
    return localStorage.setItem(this.scope, JSON.stringify(items));
  }

  getAllItems() {
    let items;
    if ((items = localStorage.getItem(this.scope))) {
      try {
        return _.filter(JSON.parse(items), item => fs.existsSync(item));
      } catch (error) {
        return [];
      }
    } else {
      return [];
    }
  }

  clear() {
    return localStorage.removeItem(this.scope);
  }
}

// View
// -------------------------
class View extends FuzzyFinderView {
  toggle(items) {
    if (this.panel != null ? this.panel.isVisible() : undefined) {
      return this.cancel();
    } else {
      this.setItems(items);
      return this.show();
    }
  }

  getEmptyMessage() {
    return 'No file opened recently';
  }
}

// Utility
// -------------------------
const notifyAndDeleteSettings = function(scope, ...params) {
  let param;
  const hasParam = param => param in atom.config.get(scope);

  const paramsToDelete = ((() => {
    const result = [];
    for (param of Array.from(params)) {       if (hasParam(param)) {
        result.push(param);
      }
    }
    return result;
  })());
  if (paramsToDelete.length === 0) { return; }

  const content = [
    `${scope}: Config options deprecated.  `,
    "Automatically removed from your `connfig.cson`  "
  ];

  for (param of Array.from(paramsToDelete)) {
    atom.config.set(`${scope}.${param}`, undefined);
    content.push(`- \`${param}\``);
  }
  return atom.notifications.addWarning(content.join("\n"), {dismissable: true});
};

// Main
// -------------------------
module.exports = {
  history: null,
  config: {
    max: {
      type: 'integer',
      default: 50,
      minimum: 1,
      description: "Max number of files to remember"
    }
  },

  activate() {
    notifyAndDeleteSettings('recent-finder', 'syncImmediately');

    // in spec-mode, we use different localStorage to avoid modification for actual storage.
    const scope = atom.inSpecMode() ? 'recent-finder-test' : 'recent-finder';
    this.history = new History(scope);
    this.subscriptions = new CompositeDisposable;
    this.subscriptions.add(atom.workspace.onDidOpen(({item}) => {
      let filePath;
      if (filePath = typeof item.getPath === 'function' ? item.getPath() : undefined) { return this.history.add(filePath); }
    })
    );

    return this.subscriptions.add(atom.commands.add('atom-workspace', {
      'recent-finder:toggle': () => this.getView().toggle(this.history.getAllItems()),
      'recent-finder:clear': () => this.history.clear()
    }
    )
    );
  },

  deactivate() {
    if (this.view != null) {
      this.view.destroy();
    }
    this.subscriptions.dispose();
    return {view: this.view, subscriptions: this.subscriptions, entries: this.entries} = {};
  },

  // I can't depend on serialize/desilialize since its per-project based.
  // serialize: ->

  getView() {
    return this.view != null ? this.view : (this.view = new View);
  }
};
