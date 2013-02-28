#!/bin/bash

set -e

#
# Goblint QuickInstall
# 
# --- TESTED WITH UBUNTU 12.04 LTS ---
# 
# REQUIRES:
# - OCaml >= 4.00.1
# - Git
#
# PROVIDES:
# - OPAM
# - findlib 1.3.3
# - camomile 0.8.3
# - batteries 1.5.0
# - Cil 
# - xml-light 2.2
# - Goblint
#

if [ -z "$FORCE_ALL" ]; then FORCE_ALL=0; fi
if [ -z "$VERBOSE" ]; then VERBOSE=0; fi

OCAML_REQUIRED="4.00.1"
OPAM_REPOSITORY="https://github.com/OCamlPro/opam.git"
GOBLINT_REPOSITORY="https://github.com/goblint/analyzer.git"

# --------------------------------------------------------------
# Helpers
error() {
    echo $@ 1>&2;
    exit 1;
}

prompt() {
    local x=0;
    echo -n $@
    echo -n " [yes/no] "
    read x
    if [[ "$x" != "yes" ]]; then
        exit 1;
    fi
}

error_log() {
    f="$1"
    echo "Error."
    cat "$f" 2> /dev/null
    exit 1
}

# --------------------------------------------------------------
# Params
path="$1"
fullClone=0
opamOnly=0

if [ "$path" == "--full-clone" ]; then path="$2"; fullClone=1; fi
if [ "$path" == "--opam-only" ]; then path=""; opamOnly=1; fi
if [ "$opamOnly" != "1" ] && [ -z "$path" ]; then
    echo "Usage: $0 [--full-clone] <Goblint Destination Directory>" 1>&2;
    echo "       $0 --opam-only" 1>&2;
    exit 1;
fi
set -u

# --------------------------------------------------------------
# Check
which ocaml >& /dev/null || error "OCaml not installed"
which git >& /dev/null || error "Git not installed"

if ! ocaml -version | grep "$OCAML_REQUIRED" >& /dev/null; then
    echo "Ocaml Version <`ocaml -version`> does not match the required one: $OCAML_REQUIRED"
    prompt "Continue anyways?"
fi

if [ "$FORCE_ALL" == "1" ] || ! which opam >& /dev/null; then installOPAM=1; else installOPAM=0; fi

# --------------------------------------------------------------
# Prepare
tmp="`mktemp -d`"
dir="`pwd`"

echo "Preparing ..."
echo "  Current Directory:   $dir"
echo "  Temporary Directory: $tmp"

# --------------------------------------------------------------
# Run Function
run() {
    msg="$1"
    cmd="$2"
    echo -n "  $msg ... "
    if [[ "$VERBOSE" == "1" ]]; then
        echo ""
        $cmd
    else
        set +e 
        $cmd 1> /dev/null 2> "$tmp/error.log"
        if [[ "$?" != "0" ]]; then error_log "$tmp/error.log"; fi
        echo "OK."
        set -e
    fi
}

# --------------------------------------------------------------
# Install OPAM
if [ "$installOPAM" != "1" ]; then
    echo "OPAM already installed."
else
    OPAM_OUT="$tmp/opam.git"
    mkdir -p "$OPAM_OUT"

    echo "Installing OPAM ..."
    echo "  Github Repository: $OPAM_REPOSITORY"
    echo "  Output Path:       $OPAM_OUT"


    run "Cloning (This may take some time.)" "git clone --depth 1 $OPAM_REPOSITORY $OPAM_OUT"
    cd "$OPAM_OUT"
    run "Configuring"  "./configure --prefix=/usr/local"
    run "Running Make" "make"
    run "Installing"   "sudo make install"
    run "Initialising" "opam init"
    cd "$dir"
    rm -rf "$OPAM_OUT"
fi
eval `opam config env`

if [[ "$opamOnly" == "1" ]]; then exit 0; fi

# --------------------------------------------------------------
# Installing Dependencies via OPAM
install_opam() {
    run "$1 (Version $2)" "opam install $1.$2"
}

echo "Installing Dependencies ..."
install_opam "ocamlfind" "1.3.3"
install_opam "camomile"  "0.8.3"
install_opam "batteries" "1.5.0"
install_opam "cil"       "1.5.1"
install_opam "xml-light" "2.2"
eval `opam config env`

# --------------------------------------------------------------
# Fetch Goblint
echo "Cloning Goblint ..."
echo "  Github Repository: $GOBLINT_REPOSITORY"
echo "  Output Path: $path"

doFetch=1

if [ -d "$path" ]; then
    echo ""
    echo "  The given Output Directory does already exist. Do you want to clone Goblint into it?"
    echo -n "  (otherwise the current contents will be used for building) [yes/no] "
    read x
    if [[ "$x" == "no" ]]; then doFetch=0; fi
    echo ""
fi

if [[ "$doFetch" == "1" ]]; then
    if [[ "$fullClone" == "1" ]]; then
        run "Fetching (complete) Repository" "git clone $GOBLINT_REPOSITORY $path"
    else
        run "Fetching Repository" "git clone --depth 1 $GOBLINT_REPOSITORY $path"
    fi
fi

cd "$path"
run "Cleanup"            "./make.sh clean"
run "Building Goblint"   "./make.sh"
cd "$dir"

echo "Done."
