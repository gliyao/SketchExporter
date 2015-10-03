#!/bin/bash -l
#!/bin/bash -l
PROJECT_DIR=$1
SKETCH_PATH=$2
ASSETS_PATH=$3

ICONS_DIR="PROJECT_DIR"/"Icons"

function exportIcons()
{
    echo `pwd`
    # export icon as pdf vector
    sketchtool export slices "$SKETCH_PATH" \
        --output="$ICONS_DIR" \
        --formats="pdf" \
        --scales="0.5"

    # create assets to XCode
    cd $ICONS_DIR

    for file in *.pdf
        do

        fname=${file%%@*}
        
        # create imageset file
        assets_name="$fname".imageset
        icon_assets_dir="$ASSETS_PATH"/"$assets_name"
        createJSONwithAssetsName "$file"
        
        # copy imageset file to XCode
        mkdir -p "$icon_assets_dir"
        /bin/cp "$file" "$icon_assets_dir"/"$file"
        /bin/cp Contents.json "$icon_assets_dir"/Contents.json
    done

    cd $PROJECT_DIR

    # remove unused files
    rm -rf "$ICONS_DIR"
}

function createJSONwithAssetsName() 
{
cat << EOF > Contents.json
{
  "images" : [
    {
      "idiom" : "universal",
      "filename" : "$1"
    }
  ],
  "info" : {
    "version" : 1,
    "author" : "xcode"
  }
}
EOF
}

# sketch flow
exportIcons
