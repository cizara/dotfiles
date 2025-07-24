dotfiles
=====
Install with GNU stow

### Vim Plugins
Install the Vim plugins:
```bash
git clone https://github.com/preservim/nerdtree.git ~/.vim/pack/vendor/start/nerdtree
git clone https://github.com/vim-airline/vim-airline ~/.vim/pack/dist/start/vim-airline

# Generate help tags with 
vim -u NONE -c "helptags ~/.vim/pack/vendor/start/nerdtree/doc" -c q
vim -u NONE -c "helptags ~/.vim/pack/vendor/start/vim-airfline/doc" -c q
```
