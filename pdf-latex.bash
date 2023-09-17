# Pre-process markdown to insert latex before generating the PDF.
BOOK_START=0
BOOK_END=0
SEC_ENTER=0
SEC_EXIT=0
SSEC_ENTER=0
SSEC_EXIT=0
PARA_ENTER=0
PARA_EXIT=0

function do_line() {
    if [[ "$line" =~ ^［ ]]; then
        echo "\\Large $line  "
    elif [[ "$line" =~ ^[[:upper:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:lower:]] ]]; then
        echo "\\small $line  "
    elif [[ "$line" =~ ^[[:punct:]] ]]; then
        echo "\\small $line  "
    else
        echo "\\Large $line  "
    fi
}

while IFS= read -r line; do

    if [[ $BOOK_END -eq 1 ]]; then
        echo "$line"
        continue
    fi

    if [[ "$line" =~ ^#[[:space:]] ]]; then
        if [[ $SEC_ENTER -eq 1 ]]; then
            SEC_EXIT=1
            # echo "%RSE-SEC-EXIT"
        fi
        if [[ $PARA_EXIT -eq 1 ]]; then
            # echo "%RSE-SEC-PARA-EXIT"
            echo "\\text{\\small\\char\"262F$~$\\char\"262F$~$\\char\"262F"}
            echo
            echo "\\egroup"
        fi
        if [[ $BOOK_START -eq 1 ]]; then
            BOOK_END=1
            # echo "%RSE-BOOK-END"
        fi
        if [[ "$line" =~ Appendix ]]; then
            BOOK_END=1
            echo "$line"
            continue
        elif [[ "$line" =~ chapters$ ]]; then
            BOOK_START=1
            BOOK_END=0
            # echo "%RSE-BOOK-START"
        fi
        echo "$line"
        SEC_ENTER=1
        SEC_EXIT=0
        # echo "%RSE-SEC-ENTER"
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    if [[ $BOOK_START -eq 0 ]]; then
        echo "$line"
        continue
    fi

    SSEC_TERMINATOR=""
    if [[ "$line" =~ ^##[[:space:]] ]]; then
        SSEC_TERMINATOR="taijitu"
    elif [[ "$line" = "---" ]]; then
        SSEC_TERMINATOR="taijitu"
    elif [[ "$line" = "***" ]]; then
        SSEC_TERMINATOR="asterisks"
    fi

    if [[ ! -z $SSEC_TERMINATOR ]]; then
        if [[ $SSEC_ENTER -eq 1 ]]; then
            SSEC_ENTER=0
            if [[ $PARA_EXIT -eq 1 ]]; then
                # echo "%RSE-SSEC-PARA-EXIT-$SSEC_TERMINATOR"
                if [[ $SSEC_TERMINATOR = taijitu ]]; then
                    echo "\\text{\\small\\char\"262F$~$\\char\"262F$~$\\char\"262F"}
                    echo
                    echo "\\clearpage"
                elif [[ $SSEC_TERMINATOR = asterisks ]]; then
                    echo \\ast$~$\\ast$~$\\ast
                fi
                echo
                echo "\\egroup"
            else
                SSEC_EXIT=1
                # echo "%RSE-SSEC-EXIT"
            fi
        fi
        if [[ "$line" =~ ^##[[:space:]] ]]; then
            echo "$line"
        fi
        SSEC_ENTER=1
        SSEC_EXIT=0
        # echo "%RSE-SSEC-ENTER"
        PARA_ENTER=0
        PARA_EXIT=0
        continue
    fi

    if [[ "$line" = "" ]]; then
        if [[ $PARA_ENTER -eq 1 ]]; then
            PARA_ENTER=0
            PARA_EXIT=1
            # echo "%RSE-PARA-EXIT"
        fi
        echo "$line"
        continue
    fi

    # Not a header or section terminator, not a blank line.

    if [[ $PARA_ENTER -eq 0 ]]; then
        PARA_ENTER=1
        if [[ $PARA_EXIT -eq 1 ]]; then
            PARA_EXIT=0
            # echo "%RSE-PARA-EXIT-ENTER"
            echo "\\egroup"
            echo "\\bgroup\\centering\\filbreak"
            do_line "$line"
            continue
        else
            # echo "%RSE-PARA-ENTER"
            echo "\\bgroup\\centering\\filbreak"
            do_line "$line"
            continue
        fi
    fi

    do_line "$line"
    continue

done < "$1"
