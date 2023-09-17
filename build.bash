# Build the ebook. Check build.md to prep build environment.
USAGE="Usage: $0 [epub|pdf] [inner|outer|other|all]"

# Check args.
case $1 in
    epub) echo -n "Building $1" ;;
    pdf) echo -n "Building $1" ;;
    *) echo $USAGE > /dev/stderr && exit 1
esac
case $2 in
    inner) echo " $2" ;;
    outer) echo " $2" ;;
    other) echo " $2" ;;
    all) echo " $2" ;;
    *) echo $USAGE > /dev/stderr && exit 1
esac

# Pre-process foreward template version.
if [[ -n $(git status -s) ]]; then
    COMMIT="#######"
    EPOCH=$(date +%s)
else
    COMMIT=$(git log -1 --format=%h)
    EPOCH=$(git log -1 --format=%ct)
    TAG=$(git describe --tags --candidates=0 $COMMIT 2>/dev/null)
    if [[ -n $TAG ]]; then
        COMMIT=$TAG
    fi
fi
DATE="@$EPOCH"
VERSION="Commit $COMMIT, $(date -d $DATE +'%B %d, %Y')."
sed "s/{{ version }}/$VERSION/g" foreward.tpl.md > foreward.md
echo "${VERSION}"

# Pre-process input files.
if [[ $2 = "inner" ]] || [[ $2 = "all" ]]; then
    SUB="Inner chapters"
    MD="InnerZhuangzi-$COMMIT.md"
    TEX="InnerZhuangzi-$COMMIT.tex.md"
    EPUB="InnerZhuangzi-$COMMIT.epub"
    PDF="InnerZhuangzi-$COMMIT.pdf"
    sed -s '$G' -s \
        foreward.md \
        01-inner/title.md \
        01-inner/01.md \
        01-inner/02.md \
        01-inner/03.md \
        01-inner/04.md \
        01-inner/05.md \
        01-inner/06.md \
        01-inner/07.md \
        shiji.md \
        canon.md \
        lynn.md \
        README.md \
        01-inner/notes.md \
        01-inner/rse-notes.md > "$MD"
fi
if [[ $2 = "outer" ]] || [[ $2 = "all" ]]; then
    SUB="Outer chapters"
    MD="OuterZhuangzi-$COMMIT.md"
    TEX="OuterZhuangzi-$COMMIT.tex.md"
    EPUB="OuterZhuangzi-$COMMIT.epub"
    PDF="OuterZhuangzi-$COMMIT.pdf"
    sed -s '$G' -s \
        foreward.md \
        02-outer/title.md \
        02-outer/10.md \
        shiji.md \
        canon.md \
        lynn.md \
        README.md \
        02-outer/notes.md \
        02-outer/rse-notes.md > "$MD"
fi
if [[ $2 = "other" ]] || [[ $2 = "all" ]]; then
    SUB="Other chapters"
    MD="OtherZhuangzi-$COMMIT.md"
    TEX="OtherZhuangzi-$COMMIT.tex.md"
    EPUB="OtherZhuangzi-$COMMIT.epub"
    PDF="OtherZhuangzi-$COMMIT.pdf"
    sed -s '$G' -s \
        foreward.md \
        03-other/title.md \
        03-other/23.md \
        03-other/29.md \
        03-other/31.md \
        03-other/33.md \
        shiji.md \
        canon.md \
        lynn.md \
        README.md \
        03-other/notes.md \
        03-other/rse-notes.md > "$MD"
fi
if [[ $2 = "all" ]]; then
    SUB="All chapters"
    MD="Zhuangzi-$COMMIT.md"
    TEX="Zhuangzi-$COMMIT.tex.md"
    EPUB="Zhuangzi-$COMMIT.epub"
    PDF="Zhuangzi-$COMMIT.pdf"
    sed -s '$G' -s \
        foreward.md \
        01-inner/title.md \
        01-inner/01.md \
        01-inner/02.md \
        01-inner/03.md \
        01-inner/04.md \
        01-inner/05.md \
        01-inner/06.md \
        01-inner/07.md \
        02-outer/title.md \
        02-outer/10.md \
        03-other/title.md \
        03-other/23.md \
        03-other/29.md \
        03-other/31.md \
        03-other/33.md \
        shiji.md \
        canon.md \
        lynn.md \
        README.md \
        01-inner/notes.md \
        01-inner/rse-notes.md \
        02-outer/notes.md \
        02-outer/rse-notes.md \
        03-other/notes.md \
        03-other/rse-notes.md > "$MD"
fi


# Build output.
if [ $1 = "epub" ]; then
    pandoc "$MD" \
        --metadata=subtitle:"$SUB" \
        --defaults epub-defaults.yaml \
        --output "${EPUB}"
    echo Built "${EPUB}"
fi
if [ $1 = "pdf" ]; then
    bash pdf-latex.bash "$MD" > "$TEX"
    pandoc "$TEX" \
        --metadata=subtitle:"$SUB" \
        --defaults pdf-defaults.yaml \
        --output "${PDF}"
    echo Built "${PDF}"
fi
