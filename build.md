# Build environment

This works on a Debian 12 host.

## Pandoc

Install packages and clone the repo.

    sudo apt install git pandoc

## EPUB

The EPUB relies entirely on system fonts.

Run the build script:

    bash build.bash epub

## PDF

To build the PDF, install TeX Live with CJK support and fonts.

    sudo apt install texlive-xetex texlive-lang-cjk fonts-noto-cjk-extra

Build the PDF.

    bash build.bash pdf

## Debug

List CJK system fonts.

    fc-list :lang=zh

Export the markdown as latex.

    pandoc -s -w latex <file>.md -o <file>.tex

Determind pandoc AST element.

    echo "<markdown>" | pandoc --from markdown --to native
