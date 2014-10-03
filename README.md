vim-fixmyjs
===========

auto fix your javascript using `fixmyjs`

How to install
-----------------------
###Vundle
Put this in your .vimrc

```vim
Bundle 'ruanyl/vim-fixmyjs'
```

Then restart vim and run `:BundleInstall`.
To update the plugin to the latest version, you can run `:BundleUpdate`.

How to use
----------

first you need to install `fixmyjs`


      npm install -g fixmyjs


For convenience it is recommended that you assign a key for this, like so:


      noremap <F3> :Fixmyjs<CR>
