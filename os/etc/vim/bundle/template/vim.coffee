#!/usr/bin/env coffee

> zx/globals:
  @rmw/thisdir

ROOT = thisdir(import.meta)
cd ROOT

< main = =>
  await $"ls #{ROOT}"
  await $'pwd'

if process.argv[1] == decodeURI (new URL(import.meta.url)).pathname
  await main()
  process.exit()
