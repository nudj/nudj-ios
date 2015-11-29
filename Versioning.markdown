# Versioning

## Preamble

The Info.plist files now get their version strings from the Apple Tool `agvtool`, and you are encouraged to read its man page.

The script `./newVersion` has been written to help with this:

* Calling `./newVersion` on its own will merely bump the build number.
* Calling `./newVersion x.y.x` will bump the build number *and* set the marketing version to "x.y.z".

## Nightly builds for QA

Nightly builds just bump the build number by calling `./newVersion` without arguments. The marketing number stays the same and Git gets tagged as "Release/x.y.z-b", where "x.y.z" is the marketing version number and "b" is the build number.

## Proposing a new release to QA

For these we call `./newVersion x.y.z`. This causes both the marketing number to change and the build number to be bumped.

## Issuing a new release to the App Store

In many cases, we will just release the last build proposed to QA. If for any reason we need to, we can simply call `./newVersion` on its own to merely bump the build number.
