{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  fetchNpmDeps,

  # Native
  writers,
  jq,
  runCommand,
  stdenv,
  rsync,
  # TODO: Remove
  breakpointHook,
}:

let
  # Create a standalone patch-shebangs executable that sources stdenv's setup
  # This is needed because the build scripts call it via npm exec(), where
  # the shell function from stdenv wouldn't be available
  patchShebangsWrapper = runCommand "patch-shebangs-wrapper" {} ''
    mkdir -p $out/bin
    cat > $out/bin/patch-shebangs << 'EOF'
#!${stdenv.shell}
source ${stdenv}/setup
patchShebangs "$@"
EOF
    chmod +x $out/bin/patch-shebangs
  '';
in

buildNpmPackage rec {
  pname = "zotero";
  version = "7.0.30";

  src = fetchFromGitHub {
    owner = "zotero";
    repo = "zotero";
    tag = version;
    hash = "sha256-mUI2dj0b6HFN9lTGkq4eDi8SEfT5pWK3vx+2FCilet8=";
    fetchSubmodules = true;
    fetchLFS = true;
  };
  # Zotero's src includes many Git submodules which also have `package-lock.json`
  # files. To prefetch the dependencies of them too, we prefetch from all lockfiles
  # in npmDeps' preBuild. The npm cache is content-addressed, so running
  # prefetch-npm-deps multiple times just accumulates packages.
  npmDeps = fetchNpmDeps {
    inherit src;
    name = "${pname}-${version}-npm-deps";
    hash = "sha256-QeYipN/pVlR31SnOz6uvdg0srxYcPITwgfPAER8KsV4=";
    # Prefetch dependencies from all submodule lockfiles
    preBuild = ''
      for lockfile in $(find . -mindepth 2 -name "package-lock.json" -type f); do
        echo "Prefetching dependencies from $lockfile"
        prefetch-npm-deps "$lockfile" "$out"
      done
    '';
    nativeBuildInputs = [
      # Needed really only if `NIX_DEBUG` is set to 1 or 2
      jq
    ];
    # Deduplicate cache index entries. Since we call prefetch-npm-deps multiple
    # times (once per submodule lockfile), the same package URL can be written to
    # the same cache index file multiple times. Without newlines, entries concatenate:
    # hash1<tab>json1hash2<tab>json2. Later, npm-config-hook.sh calls
    # `prefetch-npm-deps --map-cache` which uses split_ascii_whitespace().nth(1),
    # getting "json1hash2" and failing to parse. We detect multi-entry files by
    # counting tabs, and truncate to keep only the first entry.
    postBuild = ''
      echo "Deduplicating cache index entries..."
      for indexfile in $(find "$out/_cacache/index-v5" -type f); do
        tab_count=$(grep -o $'\t' "$indexfile" | wc -l)
        if [[ "$tab_count" -gt 1 ]]; then
          # Extract first two tab-delimited fields: hash and json1hash2
          hash=$(cut -d$'\t' -f1 "$indexfile")
          json_with_extra=$(cut -d$'\t' -f2 "$indexfile")
          # Remove last 40 chars (SHA1 hash of next entry) to get clean json1
          json="''${json_with_extra:0:-40}"
          # Write back only the first entry
          printf '%s\t%s' "$hash" "$json" > "$indexfile"

          # Debug output
          if [[ "''${NIX_DEBUG:-0}" -ge 1 ]]; then
            echo "  Deduplicated: $indexfile (had $tab_count tabs)"
          fi
          if [[ "''${NIX_DEBUG:-0}" -ge 2 ]]; then
            echo "    Package: $(echo "$json" | jq -r '.metadata.url')"
          fi
        fi
      done
    '';
  };
  makeCacheWritable = true;

  patches = [
    # Created with these changes made on a local copy, and this non-trivial
    # command:
    #
    # `git diff --submodule=diff | grep -v 'Submodule .* contains modified content'`
    #
    ./fix-build-shebangs.patch
  ];

  # Ensure npm never runs scripts during build (including in file: dependencies)
  #NPM_CONFIG_IGNORE_SCRIPTS = "1";

  #preBuild = ''
  #  # Patch shebangs in all node_modules that were created during configure
  #  patchShebangs .

  #  # Now run npm rebuild in each submodule to execute postinstall scripts with patched shebangs
  #  for dir in reader pdf-worker note-editor; do
  #    if [ -d "$dir/node_modules" ]; then
  #      echo "Running npm rebuild in $dir..."
  #      (cd "$dir" && npm rebuild)
  #    fi
  #  done
  #'';

  nativeBuildInputs = [
    (writers.writeBashBin "git" ''
      echo ${version}
    '')
    patchShebangsWrapper
    rsync
    #breakpointHook
  ];

  meta = {
    homepage = "https://www.zotero.org";
    description = "Collect, organize, cite, and share your research sources";
    mainProgram = "zotero";
    license = lib.licenses.agpl3Only;
    platforms = [
      "x86_64-linux"
      "x86_64-darwin"
      "aarch64-darwin"
    ];
    maintainers = with lib.maintainers; [
      atila
      justanotherariel
    ];
  };
}
