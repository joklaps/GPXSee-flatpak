# GPXSee-flatpak
Files needed to build the Flatpak package of GPXSee

## Releasing a new GPXSee version

Whenever upstream GPXSee publishes a new tagged release, this package needs to be
updated and rebuilt. This is done in three steps, each backed by a script, and
each step must be run before the next:

1. `./create-patch.sh <version>` — regenerates `gpxsee-appdata.patch`.
   Downloads upstream's `pkg/linux/gpxsee.appdata.xml` for the given tag and
   diffs it against our `assets/metainfo/org.gpxsee.GPXSee.metainfo.xml` to
   produce the patch applied during the build (see `org.gpxsee.GPXSee.yml`'s
   `patch` source). Any existing patch file is backed up with a timestamp
   suffix rather than overwritten.

2. `./create-manifest-yml.sh <version>` — regenerates `org.gpxsee.GPXSee.yml`.
   Downloads the upstream release tarball for the given tag, computes its
   `sha256`, and fills those values into `org.gpxsee.GPXSee.yml.template`
   (replacing the `@URL@` and `@SHA256@` placeholders) to produce the final
   manifest.

3. `./create-release.sh <version> [arch]` — builds and packages the release.
   Runs `flatpak-builder` against the manifest produced in step 2, installs
   it locally, bundles the result into `dist/gpxsee_<arch>_v<version>.flatpak`,
   and lints the manifest. `arch` defaults to `x86_64` (e.g. `aarch64` for
   other platforms).

Example, releasing version 16.11:

```
./create-patch.sh 16.11
./create-manifest-yml.sh 16.11
./create-release.sh 16.11
```

Note: `create-patch.sh` assumes GPXSee's metainfo/appdata content hasn't
diverged enough to make the diff fail cleanly — check `gpxsee-appdata.patch`
after regenerating it if upstream's file structure changed significantly.




## Docs
Info below is just for my own reference &amp; examples.

https://docs.flatpak.org/en/latest/building-introduction.html#flatpak-builder

https://docs.flathub.org/docs/for-app-authors/submission#build-and-install


### Metainfo patch

Upstream example: https://github.com/tumic0/GPXSee/blob/master/pkg/linux/gpxsee.appdata.xml

Flatpak: assets/metainfo/com.github.tumic0.GPXSee.metainfo.xml


### Prepare 

```
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install flathub --user org.flatpak.Builder
```

### Build

```
flatpak run --command=flathub-build org.flatpak.Builder --force-clean --user --install-deps-from=flathub --repo=repo --install org.gpxsee.GPXSee.yml
```

### Verify & Install

```
flatpak run --command=flathub-build org.flatpak.Builder --install org.gpxsee.GPXSee.yml
flatpak run --command=flatpak-builder-lint org.flatpak.Builder manifest org.gpxsee.GPXSee.yml
flatpak run --command=flatpak-builder-lint org.flatpak.Builder repo repo
```

### Single file bundle

```
flatpak build-bundle repo dist/gpxsee_x86_64_v16.11.flatpak org.gpxsee.GPXSee --runtime-repo=https://dl.flathub.org/repo/flathub.flatpakrepo

flatpak install dist/gpxsee_x86_64_v16.11.flatpak
```
