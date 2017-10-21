vim-fixmyjs
===========

auto fix your javascript using `eslint` or `fixmyjs` or `jscs` or `tslint`

![screenshot](https://cloud.githubusercontent.com/assets/486382/24611005/5af68f58-1889-11e7-9183-c3059a1d7849.gif)

How to install
-----------------------
### Vundle

```vim
Bundle 'ruanyl/vim-fixmyjs'
```

Then restart vim and run `:BundleInstall`.
To update the plugin to the latest version, you can run `:BundleUpdate`.

How to use
----------

1. first you need to install `fixmyjs` or `eslint` (or `tslint`)


    ```
    npm install -g fixmyjs
    or
    npm install -g eslint
    npm install -g eslint-plugin-babel
    or
    npm intall -g tslint
    ```

2. Config which autofix engine to use:

    ```
    let g:fixmyjs_engine = 'eslint' (default)
    or
    let g:fixmyjs_engine = 'fixmyjs'
    or
    let g:fixmyjs_engine = 'jscs'
    or
    let g:fixmyjs_engine = 'tslint'
    ```

3. Config `.jshintrc` or `.eslintrc` or `.jscsrc` path

    ```
    let g:fixmyjs_rc_path = 'path/to/.rc'
    ```

    OR

    if you have projects which use different rc file names, for example: one project with `.eslintrc`  but the other project has `.eslintrc.json`,
    in this case you should use (the array has an order):

    ```
    let g:fixmyjs_rc_filename = ['.eslintrc', '.eslintrc.json']
    ```

if you don't specify the path, it will try to find the `.rc` from root of your project directory, `$HOME/.rc`, `$HOME/.vim/.rc`.
Note that this plugin considers the directory where your .git directory is located as the root of your project directory. This can cause
some confusion when you have a valid `.eslintrc` config file but have not initialised git in the project directory. The plugin will fail
to execute citing `Can not find a valid config file...`.



4. For convenience it is recommended that you assign a key for this, like so:


    ```
    noremap <Leader><Leader>f :Fixmyjs<CR>
    ```

5. For fixmyjs to enable legacy mode:

    ```
    let g:fixmyjs_legacy_jshint = 1
    ```

6. (optional) if you want to use `eslint/jshint/jscs/tslint` installed anywhere other than global ones, you can use:

    ```
    " use linting tool installed locally in node_modules folder
    let g:fixmyjs_use_local = 1
    ```

    or you can config the path manually, for example:

    ```
    let g:fixmyjs_executable = 'path/to/eslint'
    ```

7. If you want to do an upwards search for a configuration file based on the current working directory, you can specify:

   ```
   " search for config file upwards recursively, falling back to other configs
   let g:fixmyjs_rc_local = 1
   ```

Sort import
----------

Please refer to [import-sort](https://github.com/renke/import-sort) for more details

Config example:
```
// enable auto sort import on write
let g:fixmyjs_sort_import_on_write = 1

// or you can do
:SortImport

// install import-sort packages
npm install --save-dev import-sort-cli import-sort-parser-babylon import-sort-parser-typescript import-sort-style-renke

// package.json:
"importSort": {
  ".js, .jsx, .es6, .es": {
    "parser": "babylon",
    "style": "renke"
  },
  ".ts, .tsx": {
    "parser": "typescript",
    "style": "renke"
  }
}
```
