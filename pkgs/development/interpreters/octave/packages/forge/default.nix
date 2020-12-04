{ callPackage
, octave
}:

# Update links.txt with:
#
#     curl --silent https://octave.sourceforge.io/packages.php |\
#       pup '.deep_links json{}' |\
#       jq --raw-output '.[] | .children[1].href' > links.txt

# Get deps of a package: ( example for "secs3d" )
#
#     curl --silent https://octave.sourceforge.io/secs3d/index.html |\
#       pup 'div.of-col:nth-child(1) > p:nth-child(2) json{}' |\
#       jq --raw-output '.[0].children[1:] | .[] | .text' > secs3d.deps

{
  callPackage
}
