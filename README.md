vim-fixmyjs
===========

auto fix your javascript using `eslint` or `fixmyjs` or `jscs`

How to install
-----------------------
###Vundle

```vim
Bundle 'ruanyl/vim-fixmyjs'
```

Then restart vim and run `:BundleInstall`.
To update the plugin to the latest version, you can run `:BundleUpdate`.

How to use
----------

1. first you need to install `fixmyjs` or `eslint`


    ```
    npm install -g fixmyjs
    or
    npm install -g eslint
    npm install -g eslint-plugin-babel
    ```

2. Config which autofix engine to use:

    ```
    let g:fixmyjs_engine = 'eslint' (default)
    or
    let g:fixmyjs_engine = 'fixmyjs'
    or
    let g:fixmyjs_engine = 'jscs'
    ```

3. Config `.jshintrc` or `.eslintrc` or `.jscsrc` path

    ```
    let g:fixmyjs_rc_path = 'path/to/.rc'
    ```
if you don't specify the path, it will try to find the `.rc` from `$HOME/.rc`, `$HOME/.vim/.rc`


4. For convenience it is recommended that you assign a key for this, like so:


    ```
    noremap <Leader><Leader>f :Fixmyjs<CR>
    ```

5. For fixmyjs to enable legacy mode:

    ```
    let g:fixmyjs_legacy_jshint = 1
    ```
