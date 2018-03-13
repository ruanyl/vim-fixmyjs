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

### vim-plug
```
Plug 'ruanyl/vim-fixmyjs'
```

How to use
----------

1. Install `fixmyjs` or `eslint` (or `tslint`) globally, or have it in project `node_modules` folder

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

3. For convenience it is recommended that you assign a key for this, like so:


    ```
    noremap <Leader><Leader>f :Fixmyjs<CR>
    ```

4. For fixmyjs to enable legacy mode:

    ```
    let g:fixmyjs_legacy_jshint = 1
    ```
