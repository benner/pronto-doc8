# Pronto runner for doc8

Pronto runner for [doc8](https://github.com/PyCQA/doc8), command-line
tool to check C/C++ files for style issues following Google's C++ style guide.
[What is Pronto?](https://github.com/prontolabs/pronto)

## Usage

* `gem install pronto-doc8`
* `pronto run`
* `PRONTO_DOC8_OPTS="--max-line-length=128" pronto run` for passing CLI options
  to `doc8`

## Contribution Guidelines

### Installation

`git clone` this repo and `cd pronto-doc8`

Ruby

```sh
rbenv install 3.1.0 # or newer
rbenv global 3.1.0 # or make it project specific
gem install bundle
bundle install
```

Make your changes

```sh
git checkout -b <new_feature>
# make your changes
bundle exec rspec
gem build pronto-doc8.gemspec
gem install pronto-doc8-<current_version>.gem
pronto run --unstaged
```

## Changelog

0.1.0 Initial public version.
