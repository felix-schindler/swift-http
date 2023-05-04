#  Changelog

## f1.0.4

- Removed all Cache things again

## f1.0.3

- Bumped dev target to iOS 15, watchOS 8, macOS 12 or newer
- Removed Linux and old iOS compatibility from UrlSessionHttpClient

## f1.0.2

- Added use of URLCache for `UrlSessionHttpClient.dataTask`

## f1.0.1

- Removed `trailingSlashEnabled`
- Better string concats

## f1.0.0

- `resource` is URL encoded
  - This doesn't work when the `HttpUrl` is initialized from an `URL`
