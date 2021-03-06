#!/bin/bash

SCRIPTNAME=`basename $0`
SUPPORT_LANG=("python" "go")

function usage {
    cat <<EOF
$SCRIPTNAME generate gRPC codes of each languages.

Usage:
    $SCRIPTNAME [subcommand] [<options>]

Subcommand:
    generate:
        generate grpc code.

        options:
            -p : proto file (required).
            -l : language (required).
            -o : output dir (required).

    list:
        show list of supported languages.

Options:
    --help, -h        print this
EOF
}

if [ "$(uname)" == 'Darwin' ]; then
  #Mac
  PROTO_CMD=./protoc-3.1.0-osx-x86_64/bin/protoc
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  #Linux
  PROTO_CMD=./protoc-3.1.0-linux-x86_64/bin/protoc
elif [ "$(expr substr $(uname -s) 1 10)" == 'MINGW32_NT' ]; then
  #'Cygwin'
  PROTO_CMD=./protoc-3.1.0-win32/bin/protoc.exe
else
  echo "Your platform ($(uname -a)) is not supported."
  exit 1
fi

function generate {
  GENERATE_USAGE="Usage: $SCRIPTNAME generate [-p PROTO] [-l LANG] [-o OUTPUT_DIR]"
  FLG_P="FALSE"
  FLG_L="FALSE"
  FLG_O="FALSE"
  while getopts l:o: OPT
  do
    case $OPT in
      "p" )
        FLG_P="TRUE"; PROTO="$OPTARG"
        ;;
      "l" )
        FLG_L="TRUE"; LANGUAGE="$OPTARG"
        ;;
      "o" )
        FLG_O="TRUE"; OUTPUT="$OPTARG"
        ;;
      * ) echo $GENERATE_USAGE 1>&2
            exit 1 ;;
    esac
  done

  if ["$FLG_P" != "TRUE"]; then
    echo '-p option is required.'
    echo $GENERATE_USAGE
    exit 2
  if [ "$FLG_L" != "TRUE" ]; then
    echo '-l option is required.'
    echo $GENERATE_USAGE
    exit 2
  fi
  if [ "$FLG_O" != "TRUE" ]; then
    echo '-o option is required.'
    echo $GENERATE_USAGE
    exit 2
  fi

  if [ "$LANGUAGE" = "python" ]; then
      python -m grpc_tools.protoc $PROTO --python_out=$OUTPUT --grpc_python_out=$OUTPUT --proto_path=./protos/
  elif [ "$LANGUAGE" = "go" ]; then
      $PROTO_CMD $PROTO --go_out=plugins=grpc:$OUTPUT --proto_path=./protos/
  else
       echo "invalid language. Supperted language is ..."
       list
       exit 3
  fi

}

function lang_list {
  echo ${SUPPORT_LANG[@]}
}

case ${1} in
    generate)
        shift
        generate $@
    ;;

    lang-list)
        lang_list
    ;;

    help|--help|-h)
        usage
    ;;

    *)
        echo "[ERROR] Invalid subcommand '${1}'"
        usage
        exit 1
    ;;
esac
