# saltcorn-store-triggers

"Saltcorn Store Sync" pack contains three triggers:

## update_ext

API Call trigger that can be passed plugin information and checks if it should be inserted or updated to `extensions` table.

Four possible formats to pass data (in JS syntax for breavity):

 1. `{name:"xxx", source:"npm", location:"xxx"}`
 2. `{plugin:{name:"xxx", source:"npm", location:"xxx"}}`
 3. `{url:"https://full-url-to-json-with-first-format"}`
 4. `{url:"/relative-url-on-client-machine-to-json-with-first-format",port:80}`

## update_pack

API Call trigger that can be passed pack information and checks if it should be inserted or updated to `packs` table.

Four possible formats to pass data (in JS syntax for breavity):

 1. `{name:"xxx", source:"npm", location:"xxx"}`
 2. `{plugin:{name:"xxx", source:"npm", location:"xxx"}}`
 3. `{url:"https://full-url-to-json-with-first-format"}`
 4. `{url:"/relative-url-on-client-machine-to-json-with-first-format",port:80}`

Last two formats (URLs) especially useful for packs, that can be larger than 1M (that's default limit of `client_max_body_size` in nginx)
and even larger than 5M (that's uncustomizable limit for Saltcorn).

## refresh_store

Daily trigger that downloads packs and extensions from official Saltcorn Store (https://store.saltcorn.com) and
calls `update_ext`/`update_pack` to refresh data in local tables for public plugins/packs.
