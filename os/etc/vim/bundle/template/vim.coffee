#!/usr/bin/env coffee

> zx/globals:
  @rmw/thisdir

< default main = =>
  ROOT = thisdir(import.meta)
  cd ROOT

  await $"ls #{ROOT}"
  await $'pwd'

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()
